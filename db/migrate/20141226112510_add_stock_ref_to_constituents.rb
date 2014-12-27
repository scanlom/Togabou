class AddStockRefToConstituents < ActiveRecord::Migration
  def change
    add_reference :constituents, :stock, index: true
  end
end
