class AddStockIdToFundamentals < ActiveRecord::Migration
  def change
    add_column :fundamentals, :stock_id, :integer
  end
end
