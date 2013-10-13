class CreateFundamentals < ActiveRecord::Migration
  def change
    create_table :fundamentals do |t|
      t.date :date
      t.text :symbol
      t.decimal :eps
      t.decimal :div
      t.decimal :pe
      t.decimal :pe_high
      t.decimal :pe_low
      t.decimal :roe
      t.decimal :roa
      t.decimal :mkt_cap
      t.decimal :shrs_out

      t.timestamps
    end
  end
end
