# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user  = User.where(email: "shiva@gmail.com").first_or_initialize
user.update!(
  password: "123456",
  password_confirmation: "123456",
  display_name: "Shiva C",
  user_name: "shiva4706"
)

100.times do |i|
  Blog.create(
    title: "Blog #{i}",
    content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod",
    is_public: true
  )
end