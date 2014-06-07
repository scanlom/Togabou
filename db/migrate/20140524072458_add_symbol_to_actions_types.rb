class AddSymbolToActionsTypes < ActiveRecord::Migration
  def change
    add_column :actions_types, :symbol, :text
  end
end
