class ChangeColumnType < ActiveRecord::Migration[7.1]
  def change
    add_index :users, :user_name, unique: true
  end
end
