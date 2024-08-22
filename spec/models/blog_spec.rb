require 'rails_helper'

RSpec.describe Blog, type: :model do

  let(:user) {
      User.create({user_name: "Shiva", display_name: "Shiva", password: "password"})
  }

  it "is a valid blog" do
    blog = Blog.new(
      title: "Title",
      content: "Content",
      is_public: true,
      user_id: user.id
    )

    expect(blog).to be_valid
  end

  it "is not valid without a user" do
    blog = Blog.new(
      title: "Title",
      content: "Content",
      is_public: true,
      user_id: nil
    )

    expect(blog).not_to be_valid
  end

  it "is not valid without a title" do
    blog = Blog.new(
      title: nil,
      content: "Content",
      is_public: true
    )

    expect(blog).not_to be_valid
  end

  it "is not valid without a content" do
    blog = Blog.new(
      title: "Title",
      content: nil,
      is_public: true
    )

    expect(blog).not_to be_valid
  end
end
