# This file runs with `bin/rails db:seed` and when `db:prepare` creates a new database.
# Dummy data is only loaded in development; use `bin/rails dev:seed` to load it explicitly.
if Rails.env.development?
  require Rails.root.join("db/seeds/dev_seeder")
  DevSeeder.call
end
