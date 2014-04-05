class CreateActionsTypes < ActiveRecord::Migration
  def change
    create_table :actions_types do |t|
      t.text :description
      t.text :value1
      t.text :value2
      t.text :value3
      t.text :value4
      t.text :value5

      t.timestamps
    end
  end
end
