class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.date :date
      t.references :actions_type, index: true
      t.text :description
      t.decimal :value1
      t.decimal :value2
      t.decimal :value3
      t.decimal :value4
      t.decimal :value5
      t.text :symbol

      t.timestamps
    end
  end
end
