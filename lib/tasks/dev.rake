namespace :dev do
  desc "Seed the database with dummy data (safe to run repeatedly)"
  task seed: :environment do
    require Rails.root.join("db/seeds/dev_seeder")
    DevSeeder.call
  end

  desc "Delete all users, receipes and ingredients, then seed dummy data again"
  task reseed: :environment do
    require Rails.root.join("db/seeds/dev_seeder")
    DevSeeder.call(reset: true)
  end
end
