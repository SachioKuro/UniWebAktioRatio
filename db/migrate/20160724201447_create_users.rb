class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :email
      t.string :password, null: false

      t.timestamps null: false
    end

    add_index :users, :username, unique: true
  end
end
