class CreatePortfolios < ActiveRecord::Migration
  def change
    create_table :portfolios do |t|
      t.text :name
      t.integer :type

      t.timestamps
    end
  end
end
