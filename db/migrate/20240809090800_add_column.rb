class AddColumn < ActiveRecord::Migration[7.1]
  def change
    add_reference :blogs, :user, index: true
  end
end
