class AddIndexToUserStocks < ActiveRecord::Migration
  def change
    #add_column :user_stocks, [:shortName, :username], :string
    add_index :user_stocks, [:shortName, :username], unique: true
  end
end
