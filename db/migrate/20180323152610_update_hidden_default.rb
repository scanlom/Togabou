class UpdateHiddenDefault < ActiveRecord::Migration[5.1]
  def change
    change_column_default :stocks, :hidden, false
  end
end
