class AddHistoricalsToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :day_change, :decimal
    add_column :stocks, :week_change, :decimal
    add_column :stocks, :month_change, :decimal
    add_column :stocks, :three_month_change, :decimal
    add_column :stocks, :year_change, :decimal
    add_column :stocks, :five_year_change, :decimal
    add_column :stocks, :ten_year_change, :decimal
  end
end
