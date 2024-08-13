class RemoveIsPublicFromBlogs < ActiveRecord::Migration[7.1]
  def change
    remove_column :blogs, :is_public, :boolean
  end
end
