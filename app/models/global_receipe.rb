class GlobalReceipe < Receipe
  def dup_to_my_receipe
    dup = self.dup

    ActiveRecord::Base.transaction do
      dup.type = "MyReceipe"
      dup.ingredients = self.ingredients
      dup.instructions = self.instructions
      dup.save!
    end

    dup
  end
end
