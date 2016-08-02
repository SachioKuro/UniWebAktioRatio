class AddBLimitAndTLimitToUserStocks < ActiveRecord::Migration
  def change
    add_column :user_stocks, :bLimit, :decimal
    add_column :user_stocks, :tLimit, :decimal
  end
end
