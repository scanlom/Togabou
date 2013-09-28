class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.text :symbol
      t.decimal :eps
      t.decimal :div
      t.decimal :growth
      t.decimal :pe_terminal
      t.decimal :payout
      t.decimal :book
      t.decimal :roe
      t.decimal :model

      t.timestamps
    end
  end
end
