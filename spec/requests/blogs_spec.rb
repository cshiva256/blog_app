require 'rails_helper'

RSpec.describe "Blogs", type: :request do

  let(:user) { User.create!(
      user_name: 'user1',
      display_name: 'User 1',
      password: 'password',
      password_confirmation: 'password'
    )}
  let(:token) {
    JsonWebToken.encode(
      user_id: user.id,
      exp: Time.now.to_i + 30.hours
    )
  }
  let (:base_url) { '/api/blogs' }

  before do
    @public_blog = Blog.create(
      title:"Public Test Blog",
      content: "This is a public test blog",
      is_public: true,
      user_id: user.id
    )
    @search_blog = Blog.create(
      title:"Search Test Blog",
      content: "This is a search test blog",
      is_public: true,
      user_id: user.id
    )
  end

  describe 'GET /api/blogs' do
    context 'when retrieving public blogs' do
      it 'returns public blogs' do
        private_blog = Blog.create(
          title:"Private Test Blog",
          content: "This is a private test blog",
          is_public: false,
          user_id: user.id
          )
        get base_url
        expect(response).to have_http_status(200)
        json = JSON.parse(response.body)
        expect(json).to include({
          'id' => @public_blog.id,
          'title' => @public_blog.title,
          'content' => @public_blog.content[:body].to_plain_text.truncate(30) + '...',
          'display_name' => @public_blog.user[:display_name]
        })
        expect(json).not_to include({
          'id' => private_blog.id,
          'title' => private_blog.title,
          'content' => private_blog.content[:body].to_plain_text.truncate(30) + '...',
          'display_name' => private_blog.user[:display_name]
        })
      end
    end

    context 'when searching for a blog' do
      it 'search in public blogs' do
        get base_url, params: { search: 'search' }
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)).to include({
          'id' => @search_blog.id,
          'title' => @search_blog.title,
          'content' => @search_blog.content[:body].to_plain_text.truncate(30) + '...',
          'display_name' => @search_blog.user[:display_name]
        })
      end
    end
  end

  describe 'GET /api/blogs/:id' do
    context 'Get A public blog' do
      it 'show a public blog' do
        get "#{base_url}/#{@public_blog.id}"
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)).to include(
          'id' => @public_blog.id,
          'title' => @public_blog.title,
          'content' => @public_blog.content[:body].to_plain_text,
          'display_name' => @public_blog.user[:display_name],
          'is_public' => @public_blog.is_public,
          'user_id' => @public_blog.user.id
        )
      end
    end

    context 'Get A private blog with login' do
      it 'show a private blog' do
        private_blog = Blog.create(
          title:"Private Test Blog",
          content: "This is a private test blog",
          is_public: false,
          user_id: user.id
        )
        get "#{base_url}/#{private_blog.id}", headers: { 'Authorization': token }
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)).to include(
          'id' => private_blog.id,
          'title' => private_blog.title,
          'content' => private_blog.content[:body].to_plain_text,
          'display_name' => private_blog.user[:display_name],
          'is_public' => private_blog.is_public,
          'user_id' => private_blog.user.id
        )
      end
    end

    context 'Get A private blog without login' do
      it 'show a private blog' do
        private_blog = Blog.create(
          title:"Private Test Blog",
          content: "This is a private test blog",
          is_public: false,
          user_id: user.id
        )
        get "#{base_url}/#{private_blog.id}"
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)["error"]).to include(
          'Unauthorized, Nil JSON web token'
        )
      end
    end

    context 'Get A private blog with invalid token' do
      it 'show a private blog' do
        private_blog = Blog.create(
          title:"Private Test Blog",
          content: "This is a private test blog",
          is_public: false,
          user_id: user.id
        )
        invalid_token = JsonWebToken.encode(
          user_id: user.id + 1,
          exp: Time.now.to_i + 30.hours
        )
        get "#{base_url}/#{private_blog.id}",
          headers: { 'Authorization': invalid_token }
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)["error"]).to include(
          "Unauthorized, Couldn't find User with 'id'="+ (user.id + 1).to_s
        )
      end
    end

    context 'Get A private blog with expired token' do
      it 'show a private blog' do
        private_blog = Blog.create(
          title:"Private Test Blog",
          content: "This is a private test blog",
          is_public: false,
          user_id: user.id
        )
        expired_token = JsonWebToken.encode(
          user_id: user.id,
          exp: Time.now.to_i - 30.hours
        )
        get "#{base_url}/#{private_blog.id}",
          headers: { 'Authorization': expired_token }
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)["error"]).to eq(
          'Unauthorized, Signature has expired'
        )
      end
    end
  end

  describe 'POST /api/blogs' do
    context 'Authorised user' do
      it 'creates a blog' do
        post base_url, params: {
          title: 'New Blog',
          content: 'This is a new blog.',
          is_public: true,
          user_id: user.id
        }, headers: { 'Authorization': token }
        expect(response).to have_http_status(201)
        expect(Blog.last.title).to eq('New Blog')
      end
    end

    context 'Unauthorised user' do
      it 'creates a blog' do
        post base_url, params: {
          title: 'New Blog',
          content: 'This is a new blog.',
          is_public: true,
          user_id: user.id
        }

        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)["error"]).to eq(
          'Unauthorized, Nil JSON web token'
        )
      end
    end

    context 'Experied Token' do
      it 'creates a blog' do
        expired_token = JsonWebToken.encode(
          user_id: user.id,
          exp: Time.now.to_i - 30.hours
        )
        post base_url, params: {
          title: 'New Blog',
          content: 'This is a new blog.',
          is_public: true,
          user_id: user.id
        }, headers: { 'Authorization': expired_token }

        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)["error"]).to eq(
          'Unauthorized, Signature has expired'
        )
      end
    end
  end

  describe 'PUT /api/blogs/:id' do
    context 'Authorised user' do
      it 'updates a blog' do
        put "#{base_url}/#{@search_blog.id}", params: {
          title: 'Updated Title',
          content: 'Updated content.',
          is_public: false,
          user_id: user.id
        }, headers: { 'Authorization': token }

        expect(response.status).to eq(200)
        @search_blog.reload
        expect(@search_blog.title).to eq('Updated Title')
      end
    end

    context 'Unauthorised user' do
      it 'updates a blog' do
        put "#{base_url}/#{@search_blog.id}", params: {
          title: 'Updated Title',
          content: 'Updated content.',
          is_public: false,
          user_id: user.id
        }

        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)["error"]).to eq(
          'Unauthorized, Nil JSON web token'
        )
      end
    end

    context 'Experied Token' do
      it 'updates a blog' do
        expired_token = JsonWebToken.encode(
          user_id: user.id,
          exp: Time.now.to_i - 30.hours
        )
        put "#{base_url}/#{@search_blog.id}",
          params: {
            title: 'Updated Title',
            content: 'Updated content.',
            is_public: false,
            user_id: user.id
          },
          headers: { 'Authorization': expired_token }

        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)["error"]).to eq(
          'Unauthorized, Signature has expired'
        )
      end
    end
  end

  describe 'DELETE /api/blogs/:id' do
    context 'Authorised user' do
      it 'deletes a blog' do
        delete "#{base_url}/#{@search_blog.id}",
          headers: { 'Authorization': token }
        expect(response).to have_http_status(:ok)
        expect(Blog.exists?(@search_blog.id)).to be_falsey
      end
    end

    context 'Unauthorised user' do
      it 'deletes a blog' do
        delete "#{base_url}/#{@search_blog.id}"
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)["error"]).to eq(
          'Unauthorized, Nil JSON web token'
        )
      end
    end

    context 'Experied Token' do
      it 'deletes a blog' do
        expired_token = JsonWebToken.encode(
          user_id: user.id,
          exp: Time.now.to_i - 30.hours
        )
        delete "#{base_url}/#{@search_blog.id}",
          headers: { 'Authorization': expired_token }
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)["error"]).to eq(
          'Unauthorized, Signature has expired'
        )
      end
    end
  end
end
