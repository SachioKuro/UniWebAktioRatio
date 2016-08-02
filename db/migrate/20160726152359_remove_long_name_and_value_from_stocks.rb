class RemoveLongNameAndValueFromStocks < ActiveRecord::Migration
  def change
    remove_column :stocks, :longName, :string
    remove_column :stocks, :value, :decimal
  end
end
