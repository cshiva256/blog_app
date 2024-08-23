require 'rails_helper'

RSpec.describe "Users", type: :request do

  let(:valid_attributes) do
    {
      user_name: 'user1',
      display_name: 'User 1',
      password: 'password',
      password_confirmation: 'password'
    }
  end
  let(:invalid_attributes) do
    {
      user_name: 'user 1',
      display_name: 'user 1',
      password: 'password',
      password_confirmation: 'password1'
    }
  end

  let(:user) { User.create!(valid_attributes) }
  let(:token) {
    JsonWebToken.encode(
      user_id: user.id,
      exp: Time.now.to_i + 30.hours
    )
  }

  describe 'POST /api/users/sign_up' do
    context 'with valid parameters' do
      it 'creates a new user and returns an access token' do
        post '/api/users/sign_up', params: valid_attributes
        expect(response).to have_http_status(201)
        json = JSON.parse(response.body)
        expect(json).to have_key('access_token')
        expect(json).to have_key('user_id')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new user' do
        post '/api/users/sign_up', params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to include(
          "Validation failed: Password confirmation doesn't match Password"
        )
      end
    end
  end

  describe 'POST /api/users/sign_in' do
    context 'with valid credentials' do
      it 'returns an access token' do
        post '/api/users/sign_in', params: {
          user_name: user.user_name,
          password: user.password
        }
        expect(response).to have_http_status(201)
        json = JSON.parse(response.body)
        expect(json).to have_key('access_token')
        expect(json).to have_key('user_id')
      end
    end

    context 'with invalid credentials' do
      it 'returns an unauthorized error' do
        post '/api/users/sign_in', params: {
          user_name: user.user_name,
          password: 'wrongpassword'
        }
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to include('Invalid user_name or password')
      end
    end
  end

  describe 'GET /api/users' do
    context 'with valid authentication' do
      it 'returns the current user' do
        get '/api/users', headers: { 'Authorization': token }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        puts json
        expect(json['user_name']).to eq(user.user_name)
      end
    end

    context 'without authentication' do
      it 'returns unauthorized error' do
        get '/api/users'
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to include('Unauthorized')
      end
    end


  end

  describe 'PUT /api/users' do
    context 'with valid parameters' do
      it 'updates the user profile and returns a new access token' do
        put '/api/users', params: {
          user_name: 'user2',
          display_name: 'User 2',
          password: user.password,
          new_password: 'newPassword',
          new_password_confirmation: 'newPassword'
        }, headers: { 'Authorization': token }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json).to have_key('access_token')
        expect(json).to have_key('user_id')
        user.reload
        expect(user.user_name).to eq('user2')
        expect(user.display_name).to eq('User 2')
      end
    end

    context 'with invalid parameters' do
      it 'returns an error if the password is invalid' do
        put '/api/users', params: {
          user_name: 'user1',
          display_name: 'User 2',
          password: 'wrongPassword'
        }, headers: { 'Authorization': token }
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to include('Invalid password')
      end
    end
  end

  describe 'DELETE /api/users' do
    context 'with valid authentication and correct password' do
      it 'deletes the user account' do
        delete '/api/users', params: {
          user_name: user.user_name,
          password: user.password
        }, headers: { 'Authorization': token }
        expect(response).to have_http_status(:ok)
        expect(User.exists?(user.id)).to be_falsey
      end
    end

    context 'with invalid password' do
      it 'returns an unauthorized error' do
        delete '/api/users', params: {
          user_name: user.user_name,
          password: 'wrongPassword'
        }, headers: { 'Authorization': token }
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to include('Invalid password')
      end
    end
  end

end
