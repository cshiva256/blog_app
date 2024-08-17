class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :authentication_keys => [:user_name]

  validates_uniqueness_of :user_name
  has_many :blogs

  def email_required?
    false
  end

  def email_changed?
    false
  end

end
