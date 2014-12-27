class RemoveTypeFromPortfolios < ActiveRecord::Migration
  def change
    remove_column :portfolios, :type, :integer
  end
end
