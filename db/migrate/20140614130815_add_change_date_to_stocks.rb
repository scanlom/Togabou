class AddChangeDateToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :day_change_date, :date
    add_column :stocks, :week_change_date, :date
    add_column :stocks, :month_change_date, :date
    add_column :stocks, :three_month_change_date, :date
    add_column :stocks, :year_change_date, :date
    add_column :stocks, :five_year_change_date, :date
    add_column :stocks, :ten_year_change_date, :date
  end
end
