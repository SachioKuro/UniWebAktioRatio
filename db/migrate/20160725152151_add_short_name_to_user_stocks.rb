class AddShortNameToUserStocks < ActiveRecord::Migration
  def change
    add_column :user_stocks, :shortName, :string
  end
end
