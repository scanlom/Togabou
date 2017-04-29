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

ActiveRecord::Schema.define(version: 20170225032746) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", primary_key: "name_local", id: :text, force: :cascade do |t|
    t.text    "name"
    t.integer "type"
    t.index ["type"], name: "fki_frgn_key_accounts_type", using: :btree
  end

  create_table "accounts_types", primary_key: "type", id: :integer, force: :cascade do |t|
    t.text    "description"
    t.text    "id"
    t.boolean "download"
  end

  create_table "actions", force: :cascade do |t|
    t.date     "date"
    t.integer  "actions_type_id"
    t.text     "description"
    t.decimal  "value1"
    t.decimal  "value2"
    t.decimal  "value3"
    t.decimal  "value4"
    t.decimal  "value5"
    t.text     "symbol"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["actions_type_id"], name: "index_actions_on_actions_type_id", using: :btree
  end

  create_table "actions_types", force: :cascade do |t|
    t.text     "description"
    t.text     "value1"
    t.text     "value2"
    t.text     "value3"
    t.text     "value4"
    t.text     "value5"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "symbol"
  end

  create_table "allocations", primary_key: "symbol", id: :text, force: :cascade do |t|
    t.text    "first"
    t.text    "secondary"
    t.integer "primary_ordinal"
    t.integer "secondary_ordinal"
  end

  create_table "balances", primary_key: "type", id: :integer, force: :cascade do |t|
    t.text    "description"
    t.float   "value"
    t.boolean "recon_cash"
    t.boolean "recon_budget_pos"
    t.boolean "recon_budget_neg"
    t.boolean "recon_liquid_pos"
    t.boolean "recon_liquid_neg"
  end

  create_table "balances_history", primary_key: ["date", "type"], force: :cascade do |t|
    t.date    "date",  null: false
    t.integer "type",  null: false
    t.float   "value"
    t.index ["type"], name: "fki_frgn_key_balances_history_type", using: :btree
  end

  create_table "constituents", force: :cascade do |t|
    t.text     "symbol"
    t.decimal  "value"
    t.decimal  "quantity"
    t.decimal  "price"
    t.integer  "pricing_type"
    t.integer  "portfolio_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "model"
    t.integer  "stock_id"
    t.index ["portfolio_id"], name: "index_constituents_on_portfolio_id", using: :btree
    t.index ["stock_id"], name: "index_constituents_on_stock_id", using: :btree
  end

  create_table "divisors", primary_key: "type", id: :integer, force: :cascade do |t|
    t.float "value"
  end

  create_table "divisors_history", primary_key: ["date", "type"], force: :cascade do |t|
    t.date    "date",  null: false
    t.integer "type",  null: false
    t.float   "value"
    t.index ["type"], name: "fki_frgn_key_divisors_history_type", using: :btree
  end

  create_table "divisors_types", primary_key: "type", id: :integer, force: :cascade do |t|
    t.text "description"
  end

  create_table "fundamentals", force: :cascade do |t|
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

  create_table "index_history", primary_key: ["date", "type"], force: :cascade do |t|
    t.date    "date",  null: false
    t.integer "type",  null: false
    t.float   "value"
    t.index ["type"], name: "fki_frgn_key_index_history_type", using: :btree
  end

  create_table "portfolio_history", primary_key: ["date", "type", "symbol"], force: :cascade do |t|
    t.date    "date",         null: false
    t.text    "symbol",       null: false
    t.float   "value"
    t.integer "type",         null: false
    t.integer "pricing_type"
    t.float   "quantity"
    t.float   "price"
    t.index ["type", "symbol"], name: "fki_frgn_key_portfolio_history_type_symbol", using: :btree
  end

  create_table "portfolios", force: :cascade do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "researches", force: :cascade do |t|
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

  create_table "spending", id: false, force: :cascade do |t|
    t.date    "date"
    t.float   "amount"
    t.text    "description"
    t.integer "type"
    t.integer "source"
    t.index ["source"], name: "fki_frgn_key_spending_source", using: :btree
  end

  create_table "spending_types", primary_key: "type", id: :integer, force: :cascade do |t|
    t.text "description"
  end

  create_table "stocks", force: :cascade do |t|
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
    t.decimal  "day_change",              default: -> { "(0)::numeric" }
    t.decimal  "week_change",             default: -> { "(0)::numeric" }
    t.decimal  "month_change",            default: -> { "(0)::numeric" }
    t.decimal  "three_month_change",      default: -> { "(0)::numeric" }
    t.decimal  "year_change",             default: -> { "(0)::numeric" }
    t.decimal  "five_year_change",        default: -> { "(0)::numeric" }
    t.decimal  "ten_year_change",         default: -> { "(0)::numeric" }
    t.date     "day_change_date"
    t.date     "week_change_date"
    t.date     "month_change_date"
    t.date     "three_month_change_date"
    t.date     "year_change_date"
    t.date     "five_year_change_date"
    t.date     "ten_year_change_date"
    t.boolean  "hidden"
  end

  add_foreign_key "accounts", "accounts_types", column: "type", primary_key: "type", name: "frgn_key_accounts_type"
  add_foreign_key "accounts", "divisors_types", column: "type", primary_key: "type", name: "frgn_key_divisors_type"
  add_foreign_key "balances_history", "balances", column: "type", primary_key: "type", name: "frgn_key_balances_history_type"
  add_foreign_key "divisors_history", "divisors_types", column: "type", primary_key: "type", name: "frgn_key_divisors_history_type"
  add_foreign_key "index_history", "divisors_types", column: "type", primary_key: "type", name: "frgn_key_index_history_type"
  add_foreign_key "spending", "balances", column: "source", primary_key: "type", name: "frgn_key_spending_source"
  add_foreign_key "spending_types", "spending_types", column: "type", primary_key: "type", name: "frgn_key_spending_type"
end
