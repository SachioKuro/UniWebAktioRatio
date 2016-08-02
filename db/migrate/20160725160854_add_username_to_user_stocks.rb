class AddUsernameToUserStocks < ActiveRecord::Migration
  def change
    add_column :user_stocks, :username, :string
  end
end
