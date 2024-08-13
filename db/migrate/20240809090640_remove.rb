class Remove < ActiveRecord::Migration[7.1]
  def change
    remove_column :blogs, :user_id_id
  end
end
