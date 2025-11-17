# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_17_163605) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "ingredients", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "unique_receipe_name", unique: true
  end

  create_table "instructions", force: :cascade do |t|
    t.bigint "receipe_id", null: false
    t.integer "step", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["receipe_id"], name: "index_instructions_on_receipe_id"
  end

  create_table "receipe_ingredients", force: :cascade do |t|
    t.bigint "receipe_id", null: false
    t.bigint "ingredient_id", null: false
    t.string "quantity"
    t.string "unit"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ingredient_id"], name: "index_receipe_ingredients_on_ingredient_id"
    t.index ["receipe_id"], name: "index_receipe_ingredients_on_receipe_id"
  end

  create_table "receipes", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.text "instructions"
    t.string "prep_time"
    t.string "cook_time"
    t.string "servings"
    t.string "tags", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "type", null: false
    t.bigint "global_receipe_id"
    t.string "status", null: false
    t.string "url"
    t.index ["global_receipe_id"], name: "index_receipes_on_global_receipe_id"
    t.index ["user_id"], name: "index_receipes_on_user_id"
  end

  create_table "user_filters", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "kind"
    t.jsonb "filters", default: {}
    t.integer "pagination_page"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "kind"], name: "index_user_filters_on_user_id_and_kind", unique: true
    t.index ["user_id"], name: "index_user_filters_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "unique_emails", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "instructions", "receipes", on_delete: :cascade
  add_foreign_key "receipe_ingredients", "ingredients", on_delete: :cascade
  add_foreign_key "receipe_ingredients", "receipes", on_delete: :cascade
  add_foreign_key "receipes", "receipes", column: "global_receipe_id"
  add_foreign_key "receipes", "users", on_delete: :cascade
  add_foreign_key "user_filters", "users"
end
