class AddBActiveAndTActiveToUserStocks < ActiveRecord::Migration
  def change
    add_column :user_stocks, :bActive, :boolean
    add_column :user_stocks, :tActive, :boolean
  end
end
