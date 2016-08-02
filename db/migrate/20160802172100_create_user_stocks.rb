class CreateUserStocks < ActiveRecord::Migration
  def change
    create_table :user_stocks do |t|
      t.string :username
      t.string :shortName
      t.string :bLimit
      t.string :tLimit
      t.boolean :bActive, default: false
      t.boolean :tActive, default: false
    end
  end
end
