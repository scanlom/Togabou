class AddHiddenToStocks < ActiveRecord::Migration[5.0]
  def change
    add_column :stocks, :hidden, :boolean
  end
end
