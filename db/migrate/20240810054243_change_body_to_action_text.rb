class ChangeBodyToActionText < ActiveRecord::Migration[7.1]
  def change
    Blog.all.find_each do |blog|
      blog.update(:content => blog.body)
    end

    remove_column :blogs, :body
  end
end
