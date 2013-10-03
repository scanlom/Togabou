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

ActiveRecord::Schema.define(version: 20131001213919) do

  create_table "accounts", id: false, force: true do |t|
    t.text    "name"
    t.text    "name_local", null: false
    t.integer "type"
  end

  add_index "accounts", ["type"], name: "fki_frgn_key_accounts_type", using: :btree

  create_table "accounts_types", id: false, force: true do |t|
    t.integer "type",        null: false
    t.text    "description"
    t.text    "id"
    t.boolean "download"
  end

  create_table "allocations", id: false, force: true do |t|
    t.text    "symbol",            null: false
    t.text    "first"
    t.text    "secondary"
    t.integer "primary_ordinal"
    t.integer "secondary_ordinal"
  end

  create_table "balances", id: false, force: true do |t|
    t.integer "type",             null: false
    t.text    "description"
    t.float   "value"
    t.boolean "recon_cash"
    t.boolean "recon_budget_pos"
    t.boolean "recon_budget_neg"
  end

  create_table "balances_history", id: false, force: true do |t|
    t.date    "date",  null: false
    t.integer "type",  null: false
    t.float   "value"
  end

  add_index "balances_history", ["type"], name: "fki_frgn_key_balances_history_type", using: :btree

  create_table "divisors", id: false, force: true do |t|
    t.integer "type",  null: false
    t.float   "value"
  end

  create_table "divisors_history", id: false, force: true do |t|
    t.date    "date",  null: false
    t.integer "type",  null: false
    t.float   "value"
  end

  add_index "divisors_history", ["type"], name: "fki_frgn_key_divisors_history_type", using: :btree

  create_table "divisors_types", id: false, force: true do |t|
    t.integer "type",        null: false
    t.text    "description"
  end

  create_table "fundamentals", force: true do |t|
    t.date     "date"
    t.text     "symbol"
    t.decimal  "eps"
    t.decimal  "div"
    t.decimal  "pe"
    t.decimal  "pe_high"
    t.decimal  "pe_low"
    t.decimal  "roe"
    t.decimal  "roa"
    t.decimal  "mkt_cap"
    t.decimal  "shrs_out"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "stock_id"
  end

  create_table "history", id: false, force: true do |t|
    t.date    "date"
    t.integer "type"
    t.text    "description"
    t.float   "value1"
    t.float   "value2"
    t.float   "value3"
    t.float   "value4"
    t.float   "value5"
    t.text    "symbol"
  end

  add_index "history", ["type"], name: "fki_frgn_key_history_type", using: :btree

  create_table "history_types", id: false, force: true do |t|
    t.integer "type",        null: false
    t.text    "description"
    t.text    "value1"
    t.text    "value2"
    t.text    "value3"
    t.text    "value4"
    t.text    "value5"
  end

  create_table "index_history", id: false, force: true do |t|
    t.date    "date",  null: false
    t.integer "type",  null: false
    t.float   "value"
  end

  add_index "index_history", ["type"], name: "fki_frgn_key_index_history_type", using: :btree

  create_table "portfolio", id: false, force: true do |t|
    t.text    "symbol",       null: false
    t.float   "value"
    t.integer "type",         null: false
    t.integer "pricing_type"
    t.float   "quantity"
    t.float   "price"
  end

  create_table "portfolio_history", id: false, force: true do |t|
    t.date    "date",         null: false
    t.text    "symbol",       null: false
    t.float   "value"
    t.integer "type",         null: false
    t.integer "pricing_type"
    t.float   "quantity"
    t.float   "price"
  end

  add_index "portfolio_history", ["type", "symbol"], name: "fki_frgn_key_portfolio_history_type_symbol", using: :btree

  create_table "researches", force: true do |t|
    t.text     "symbol"
    t.date     "date"
    t.decimal  "eps"
    t.decimal  "div"
    t.decimal  "growth"
    t.decimal  "pe_terminal"
    t.decimal  "payout"
    t.decimal  "book"
    t.decimal  "roe"
    t.decimal  "price"
    t.decimal  "div_plus_growth"
    t.decimal  "eps_yield"
    t.decimal  "div_yield"
    t.decimal  "five_year_cagr"
    t.decimal  "ten_year_cagr"
    t.decimal  "five_year_croe"
    t.decimal  "ten_year_croe"
    t.date     "eps_yr1_date"
    t.decimal  "eps_yr1"
    t.date     "eps_yr2_date"
    t.decimal  "eps_yr2"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "stock_id"
  end

  create_table "spending", id: false, force: true do |t|
    t.date    "date"
    t.float   "amount"
    t.text    "description"
    t.integer "type"
    t.integer "source"
  end

  add_index "spending", ["source"], name: "fki_frgn_key_spending_source", using: :btree

  create_table "spending_types", id: false, force: true do |t|
    t.integer "type",        null: false
    t.text    "description"
  end

  create_table "stocks", force: true do |t|
    t.text     "symbol"
    t.decimal  "eps"
    t.decimal  "div"
    t.decimal  "growth"
    t.decimal  "pe_terminal"
    t.decimal  "payout"
    t.decimal  "book"
    t.decimal  "roe"
    t.decimal  "model"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "price"
  end

end
