class AddAssociationForUsersAndBlogs < ActiveRecord::Migration[7.1]
  def change
    add_reference :blogs, :user_id, index: true
  end
end
