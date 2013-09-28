class AddStockIdToResearches < ActiveRecord::Migration
  def change
    add_column :researches, :stock_id, :integer
  end
end
