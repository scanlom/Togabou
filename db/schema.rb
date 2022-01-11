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

ActiveRecord::Schema.define(version: 2022_01_11_135314) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", primary_key: "name_local", id: :text, force: :cascade do |t|
    t.text "name"
    t.integer "type"
    t.index ["type"], name: "fki_frgn_key_accounts_type"
  end

  create_table "accounts_types", primary_key: "type", id: :integer, default: nil, force: :cascade do |t|
    t.text "description"
    t.text "id"
    t.boolean "download"
  end

  create_table "actions", id: :serial, force: :cascade do |t|
    t.date "date"
    t.integer "actions_type_id"
    t.text "description"
    t.decimal "value1"
    t.decimal "value2"
    t.decimal "value3"
    t.decimal "value4"
    t.decimal "value5"
    t.text "symbol"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["actions_type_id"], name: "index_actions_on_actions_type_id"
  end

  create_table "actions_types", id: :serial, force: :cascade do |t|
    t.text "description"
    t.text "value1"
    t.text "value2"
    t.text "value3"
    t.text "value4"
    t.text "value5"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "symbol"
  end

  create_table "allocations", primary_key: "symbol", id: :text, force: :cascade do |t|
    t.text "first"
    t.text "secondary"
    t.integer "primary_ordinal"
    t.integer "secondary_ordinal"
  end

  create_table "balances", primary_key: "type", id: :integer, default: nil, force: :cascade do |t|
    t.text "description"
    t.decimal "value", precision: 12, scale: 2
    t.boolean "recon_cash"
    t.boolean "recon_budget_pos"
    t.boolean "recon_budget_neg"
  end

  create_table "balances_history", primary_key: ["date", "type"], force: :cascade do |t|
    t.date "date", null: false
    t.integer "type", null: false
    t.decimal "value", precision: 12, scale: 2
    t.index ["type"], name: "fki_frgn_key_balances_history_type"
  end

  create_table "constituents", id: :serial, force: :cascade do |t|
    t.text "symbol"
    t.decimal "value", precision: 12, scale: 2
    t.decimal "quantity", precision: 13, scale: 3
    t.decimal "price", precision: 12, scale: 2
    t.integer "pricing_type"
    t.integer "portfolio_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "model", precision: 3, scale: 2
    t.integer "stock_id"
    t.index ["portfolio_id"], name: "index_constituents_on_portfolio_id"
    t.index ["stock_id"], name: "index_constituents_on_stock_id"
  end

  create_table "divisors", primary_key: "type", id: :integer, default: nil, force: :cascade do |t|
    t.decimal "value", precision: 26, scale: 25
  end

  create_table "divisors_history", primary_key: ["date", "type"], force: :cascade do |t|
    t.date "date", null: false
    t.integer "type", null: false
    t.decimal "value", precision: 26, scale: 25
    t.index ["type"], name: "fki_frgn_key_divisors_history_type"
  end

  create_table "divisors_types", primary_key: "type", id: :integer, default: nil, force: :cascade do |t|
    t.text "description"
  end

  create_table "fundamentals", id: :serial, force: :cascade do |t|
    t.date "date"
    t.text "symbol"
    t.decimal "eps", precision: 12, scale: 2
    t.decimal "div", precision: 13, scale: 3
    t.decimal "pe", precision: 10
    t.decimal "pe_high", precision: 10
    t.decimal "pe_low", precision: 10
    t.decimal "roe", precision: 5, scale: 2
    t.decimal "roa", precision: 5, scale: 2
    t.decimal "mkt_cap", precision: 15
    t.decimal "shrs_out", precision: 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "stock_id"
  end

  create_table "index_history", primary_key: ["date", "type"], force: :cascade do |t|
    t.date "date", null: false
    t.integer "type", null: false
    t.decimal "value", precision: 12, scale: 2
    t.index ["type"], name: "fki_frgn_key_index_history_type"
  end

  create_table "portfolio_history", primary_key: ["date", "type", "symbol"], force: :cascade do |t|
    t.date "date", null: false
    t.text "symbol", null: false
    t.decimal "value", precision: 12, scale: 2
    t.integer "type", null: false
    t.integer "pricing_type"
    t.decimal "quantity", precision: 13, scale: 3
    t.decimal "price", precision: 12, scale: 2
    t.index ["type", "symbol"], name: "fki_frgn_key_portfolio_history_type_symbol"
  end

  create_table "portfolios", id: :serial, force: :cascade do |t|
    t.text "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "researches", id: :serial, force: :cascade do |t|
    t.text "symbol"
    t.date "date"
    t.decimal "eps", precision: 12, scale: 2
    t.decimal "div", precision: 13, scale: 3
    t.decimal "growth", precision: 5, scale: 2
    t.decimal "pe_terminal", precision: 10
    t.decimal "payout", precision: 5, scale: 2
    t.decimal "book", precision: 12, scale: 2
    t.decimal "roe", precision: 5, scale: 2
    t.decimal "price", precision: 12, scale: 2
    t.decimal "div_plus_growth", precision: 10, scale: 4
    t.decimal "eps_yield", precision: 10, scale: 4
    t.decimal "div_yield", precision: 10, scale: 4
    t.decimal "five_year_cagr", precision: 10, scale: 4
    t.decimal "ten_year_cagr", precision: 10, scale: 4
    t.decimal "five_year_croe", precision: 10, scale: 4
    t.decimal "ten_year_croe", precision: 10, scale: 4
    t.date "eps_yr1_date"
    t.decimal "eps_yr1", precision: 12, scale: 2
    t.date "eps_yr2_date"
    t.decimal "eps_yr2", precision: 12, scale: 2
    t.text "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "stock_id"
  end

  create_table "spending", id: :serial, force: :cascade do |t|
    t.date "date"
    t.decimal "amount", precision: 12, scale: 2
    t.text "description"
    t.integer "type"
    t.integer "source"
    t.index ["source"], name: "fki_frgn_key_spending_source"
  end

  create_table "spending_types", primary_key: "type", id: :integer, default: nil, force: :cascade do |t|
    t.text "description"
  end

  create_table "stocks", id: :serial, force: :cascade do |t|
    t.text "symbol"
    t.decimal "eps", precision: 12, scale: 2
    t.decimal "div", precision: 13, scale: 3
    t.decimal "growth", precision: 5, scale: 2
    t.decimal "pe_terminal", precision: 10
    t.decimal "payout", precision: 5, scale: 2
    t.decimal "book", precision: 12, scale: 2
    t.decimal "roe", precision: 5, scale: 2
    t.decimal "model", precision: 3, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "price", precision: 12, scale: 2
    t.decimal "day_change", precision: 10, scale: 4, default: -> { "(0)::numeric" }
    t.decimal "week_change", precision: 10, scale: 4, default: -> { "(0)::numeric" }
    t.decimal "month_change", precision: 10, scale: 4, default: -> { "(0)::numeric" }
    t.decimal "three_month_change", precision: 10, scale: 4, default: -> { "(0)::numeric" }
    t.decimal "year_change", precision: 10, scale: 4, default: -> { "(0)::numeric" }
    t.decimal "five_year_change", precision: 10, scale: 4, default: -> { "(0)::numeric" }
    t.decimal "ten_year_change", precision: 10, scale: 4, default: -> { "(0)::numeric" }
    t.date "day_change_date"
    t.date "week_change_date"
    t.date "month_change_date"
    t.date "three_month_change_date"
    t.date "year_change_date"
    t.date "five_year_change_date"
    t.date "ten_year_change_date"
    t.boolean "hidden", default: false
  end

  add_foreign_key "accounts", "accounts_types", column: "type", primary_key: "type", name: "frgn_key_accounts_type"
  add_foreign_key "balances_history", "balances", column: "type", primary_key: "type", name: "frgn_key_balances_history_type"
  add_foreign_key "divisors_history", "divisors_types", column: "type", primary_key: "type", name: "frgn_key_divisors_history_type"
  add_foreign_key "index_history", "divisors_types", column: "type", primary_key: "type", name: "frgn_key_index_history_type"
  add_foreign_key "spending", "balances", column: "source", primary_key: "type", name: "frgn_key_spending_source"
end
