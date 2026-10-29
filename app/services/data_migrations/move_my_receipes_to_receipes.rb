module DataMigrations
  # One-off move for receipes created before the Receipes tab owned creation.
  #
  # Those receipes exist only as MyReceipe rows with no global_receipe_id. Each one becomes a GlobalReceipe
  # in the Receipes tab, authored by the same user:
  #   * published rows get a new public receipe, and the MyReceipe row is linked to it (it stays as the creator's copy)
  #   * draft rows get a new draft receipe, and the old MyReceipe draft is deleted once the new one is verified
  #
  # Safe to run more than once: linked rows are skipped, and moved drafts no longer exist as MyReceipe rows.
  class MoveMyReceipesToReceipes
    Summary = Struct.new(:published_moved, :drafts_moved, :skipped, :failed, keyword_init: true)

    attr_reader :dry_run, :output

    def initialize(dry_run: true, output: $stdout)
      @dry_run = dry_run
      @output = output
    end

    def call
      summary = Summary.new(published_moved: 0, drafts_moved: 0, skipped: 0, failed: 0)

      candidates.find_each do |my_receipe|
        outcome = move(my_receipe)
        summary[outcome] += 1
      end

      log_summary(summary)
      summary
    end

    private

    def candidates
      MyReceipe.where(global_receipe_id: nil).order(:id)
    end

    def move(my_receipe)
      label = "MyReceipe ##{my_receipe.id} \"#{my_receipe.name}\" (#{my_receipe.status}, user ##{my_receipe.user_id})"

      if dry_run
        output.puts "[dry run] would move #{label}"
        return my_receipe.published? ? :published_moved : :drafts_moved
      end

      ActiveRecord::Base.transaction do
        receipe = build_receipe(my_receipe)
        verify!(my_receipe, receipe)

        if my_receipe.published?
          my_receipe.update!(global_receipe: receipe)
          output.puts "moved #{label} -> GlobalReceipe ##{receipe.id}"
          :published_moved
        else
          my_receipe.destroy!
          output.puts "moved draft #{label} -> GlobalReceipe ##{receipe.id}"
          :drafts_moved
        end
      end
    rescue StandardError => e
      output.puts "FAILED #{label}: #{e.class}: #{e.message}"
      :failed
    end

    def build_receipe(my_receipe)
      receipe = GlobalReceipe.new(
        name: my_receipe.name,
        description: my_receipe.description,
        prep_time: my_receipe.prep_time,
        cook_time: my_receipe.cook_time,
        servings: my_receipe.servings,
        tags: my_receipe.tags,
        status: my_receipe.status,
        author: my_receipe.user
      )
      receipe.save!

      my_receipe.receipe_ingredients.each do |receipe_ingredient|
        receipe.receipe_ingredients.create!(
          ingredient: receipe_ingredient.ingredient,
          quantity: receipe_ingredient.quantity,
          unit: receipe_ingredient.unit,
          notes: receipe_ingredient.notes
        )
      end

      my_receipe.instructions.each do |instruction|
        receipe.instructions.create!(step: instruction.step, body: instruction.body)
      end

      ReceipeService::CopyImage.call(from: my_receipe, to: receipe)
      receipe
    end

    # Stops the move before anything is deleted if the new receipe is missing something
    def verify!(my_receipe, receipe)
      raise "new receipe was not saved" unless receipe.persisted?
      raise "ingredient count differs" unless receipe.receipe_ingredients.count == my_receipe.receipe_ingredients.count
      raise "instruction count differs" unless receipe.instructions.count == my_receipe.instructions.count
      raise "image was not copied" if my_receipe.image.attached? && !receipe.image.attached?
    end

    def log_summary(summary)
      output.puts
      output.puts(dry_run ? "Dry run, nothing changed:" : "Done:")
      output.puts "  published moved: #{summary.published_moved}"
      output.puts "  drafts moved:    #{summary.drafts_moved}"
      output.puts "  failed:          #{summary.failed}"
    end
  end
end
