class AddModelToConstituents < ActiveRecord::Migration
  def change
    add_column :constituents, :model, :decimal
  end
end
