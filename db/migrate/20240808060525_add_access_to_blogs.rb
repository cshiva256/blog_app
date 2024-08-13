class AddAccessToBlogs < ActiveRecord::Migration[7.1]
  def change
    add_column :blogs, :is_public, :boolean, default:false
  end
end
