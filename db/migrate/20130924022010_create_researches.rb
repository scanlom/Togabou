class CreateResearches < ActiveRecord::Migration
  def change
    create_table :researches do |t|
      t.text :symbol
      t.date :date
      t.decimal :eps
      t.decimal :div
      t.decimal :growth
      t.decimal :pe_terminal
      t.decimal :payout
      t.decimal :book
      t.decimal :roe
      t.decimal :price
      t.decimal :div_plus_growth
      t.decimal :eps_yield
      t.decimal :div_yield
      t.decimal :five_year_cagr
      t.decimal :ten_year_cagr
      t.decimal :five_year_croe
      t.decimal :ten_year_croe
      t.date :eps_yr1_date
      t.decimal :eps_yr1
      t.date :eps_yr2_date
      t.decimal :eps_yr2
      t.text :comment

      t.timestamps
    end
  end
end
