# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140527223572) do

  create_table "codtls_connections", force: true do |t|
    t.string  "ip"
    t.string  "session_id"
    t.integer "epoch"
    t.integer "seq_num_r"
    t.integer "seq_num_w"
    t.binary  "key_block"
    t.binary  "key_block_new"
    t.boolean "handshake"
  end

  create_table "codtls_devices", force: true do |t|
    t.binary "uuid"
    t.string "psk"
    t.string "psk_new"
    t.string "desc"
  end

  create_table "devices", force: true do |t|
    t.string   "name"
    t.string   "address"
    t.integer  "status",     default: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", force: true do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups_resources", id: false, force: true do |t|
    t.integer "resource_id"
    t.integer "group_id"
  end

  create_table "groups_torf_rules", id: false, force: true do |t|
    t.integer "group_id"
    t.integer "torf_rule_id"
  end

  create_table "notifications", force: true do |t|
    t.string   "text",                       null: false
    t.boolean  "read",       default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resources", force: true do |t|
    t.string   "name"
    t.string   "resource_type"
    t.string   "interface_type"
    t.string   "unit"
    t.string   "path"
    t.integer  "device_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "resources", ["device_id"], name: "index_resources_on_device_id"

  create_table "session_tokens", force: true do |t|
    t.string   "token",      null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "session_tokens", ["token"], name: "index_session_tokens_on_token"
  add_index "session_tokens", ["user_id"], name: "index_session_tokens_on_user_id"

  create_table "state_child_associations", force: true do |t|
    t.integer "torf_state_id"
    t.integer "parent_state_id"
  end

  create_table "state_parent_associations", force: true do |t|
    t.integer "torf_state_id"
    t.integer "child_state_id"
  end

  create_table "torf_actions", force: true do |t|
    t.integer  "torf_resource_id"
    t.integer  "torf_rule_id"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "torf_complex_matchers", force: true do |t|
    t.integer  "torf_rule_id"
    t.integer  "torf_state_id"
    t.integer  "parent_complex_matcher_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "torf_resources", force: true do |t|
    t.string   "name"
    t.integer  "default_value",   default: 0
    t.integer  "value"
    t.integer  "through_rule"
    t.boolean  "toggled_by_user", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "torf_resources_rules", force: true do |t|
    t.integer "torf_resource_id"
    t.integer "torf_rule_id"
  end

  create_table "torf_resources_states", force: true do |t|
    t.integer "torf_resource_id"
    t.integer "torf_state_id"
  end

  create_table "torf_rules", force: true do |t|
    t.string   "name",                       null: false
    t.integer  "priority"
    t.boolean  "enabled",    default: true
    t.boolean  "is_active",  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "torf_rules_states", force: true do |t|
    t.integer "torf_rule_id"
    t.integer "torf_state_id"
  end

  create_table "torf_simple_matchers", force: true do |t|
    t.integer  "torf_rule_id"
    t.integer  "torf_complex_matcher_id"
    t.integer  "torf_resource_id"
    t.integer  "torf_state_id"
    t.string   "type"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "torf_states", force: true do |t|
    t.string   "name",                         null: false
    t.integer  "torf_rule_id"
    t.boolean  "is_fulfilled", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",              null: false
    t.string   "encrypted_password", null: false
    t.string   "salt",               null: false
    t.string   "username",           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["username"], name: "index_users_on_username", unique: true

end
