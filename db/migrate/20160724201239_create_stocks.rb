class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.string :shortName
      t.string :longName
      t.decimal :value

      t.timestamps null: false
    end
  end
end
