class Blog < ApplicationRecord

  has_rich_text :content
  belongs_to :user

  validates :title, presence: true
  validates :content, presence: true
end
