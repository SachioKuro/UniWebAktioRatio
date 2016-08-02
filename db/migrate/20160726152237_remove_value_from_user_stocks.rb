class RemoveValueFromUserStocks < ActiveRecord::Migration
  def change
    remove_column :user_stocks, :value, :decimal
  end
end
