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

ActiveRecord::Schema[8.0].define(version: 2025_10_04_201105) do
  create_table "missive_dispatches", force: :cascade do |t|
    t.integer "subscriber_id", null: false
    t.integer "message_id", null: false
    t.string "postmark_message_stream_id"
    t.string "postmark_message_id"
    t.datetime "sent_at"
    t.datetime "delivered_at"
    t.datetime "opened_at"
    t.datetime "clicked_at"
    t.datetime "suppressed_at"
    t.integer "suppression_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_missive_dispatches_on_message_id"
    t.index ["subscriber_id", "message_id"], name: "index_missive_dispatches_on_subscriber_id_and_message_id", unique: true
    t.index ["subscriber_id"], name: "index_missive_dispatches_on_subscriber_id"
  end

  create_table "missive_lists", force: :cascade do |t|
    t.string "name", null: false
    t.integer "subscriptions_count", default: 0
    t.integer "messages_count", default: 0
    t.datetime "last_message_sent_at"
    t.string "postmark_message_stream_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "missive_messages", force: :cascade do |t|
    t.string "subject", null: false
    t.integer "dispatches_count", default: 0
    t.integer "list_id", null: false
    t.string "postmark_message_stream_id"
    t.datetime "sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["list_id"], name: "index_missive_messages_on_list_id"
  end

  create_table "missive_subscribers", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "suppressed_at"
    t.integer "suppression_reason"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_missive_subscribers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "missive_dispatches", "missive_messages", column: "message_id"
  add_foreign_key "missive_dispatches", "missive_subscribers", column: "subscriber_id"
  add_foreign_key "missive_messages", "missive_lists", column: "list_id"
  add_foreign_key "missive_subscribers", "users"
end
