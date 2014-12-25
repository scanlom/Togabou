class CreateConstituents < ActiveRecord::Migration
  def change
    create_table :constituents do |t|
      t.text :symbol
      t.decimal :value
      t.decimal :quantity
      t.decimal :price
      t.integer :pricing_type
      t.references :portfolio, index: true

      t.timestamps
    end
  end
end
