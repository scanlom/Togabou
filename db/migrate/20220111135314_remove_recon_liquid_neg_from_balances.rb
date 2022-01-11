class RemoveReconLiquidNegFromBalances < ActiveRecord::Migration[6.1]
  def change
    remove_column :balances, :recon_liquid_neg, :boolean
  end
end
