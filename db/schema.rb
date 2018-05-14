# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_05_08_134054) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "login"
    t.string "password_digest", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_token_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_accounts_on_confirmation_token"
    t.index ["login"], name: "index_accounts_on_login"
    t.index ["reset_password_token"], name: "index_accounts_on_reset_password_token"
  end

  create_table "fields", force: :cascade do |t|
    t.integer "input_type", comment: "Field's type: password, email or text"
    t.string "title", comment: "Field's title"
    t.string "name", comment: "Field's name"
    t.integer "order", default: 0, comment: "Field's order"
    t.string "value", comment: "Encrypted field's value"
    t.bigint "note_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["note_id"], name: "index_fields_on_note_id"
  end

  create_table "group_relationships", force: :cascade do |t|
    t.integer "user_role", comment: "User's role in group"
    t.bigint "group_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_relationships_on_group_id"
    t.index ["user_id"], name: "index_group_relationships_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups_notes", force: :cascade do |t|
    t.bigint "group_id"
    t.bigint "note_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_groups_notes_on_group_id"
    t.index ["note_id"], name: "index_groups_notes_on_note_id"
  end

  create_table "notes", force: :cascade do |t|
    t.string "title", comment: "Note's title"
    t.bigint "template_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["template_id"], name: "index_notes_on_template_id"
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "templates", force: :cascade do |t|
    t.string "title", comment: "Template's title"
    t.json "config", comment: "Template's config(fields set with types and order)"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_templates_on_user_id"
  end

  create_table "tokens", force: :cascade do |t|
    t.string "value"
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_tokens_on_account_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "phone"
    t.bigint "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_users_on_account_id"
  end

end
