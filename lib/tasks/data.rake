namespace :data do
  desc "Move receipes created in My receipes into the Receipes tab. Dry run unless DRY_RUN=0. Safe to run again."
  task move_my_receipes_to_receipes: :environment do
    abort "data:move_my_receipes_to_receipes does not run in the test environment" if Rails.env.test?

    dry_run = ENV.fetch("DRY_RUN", "1") != "0"
    DataMigrations::MoveMyReceipesToReceipes.new(dry_run:).call
  end
end
