class RemoveColumnFromModel2 < ActiveRecord::Migration
  def change
      remove_column :user_stocks, :time
  end
end
