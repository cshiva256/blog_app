module Users
  class Api < Grape::API
    prefix :api
    format :json

    helpers do
      def authenticate_user!
        token = headers["Authorization"]
        begin
          decoded = JsonWebToken.decode(token)
          @current_user = User.find(decoded[:user_id])
        rescue ActiveRecord::RecordNotFound => e
          error!('Unauthorized, ' + e.message, 401)
        rescue JWT::DecodeError => e
          error!('Unauthorized, ' + e.message, 401)
        rescue => e
          error!(e.message, 401)
        end
      end
    end

    include ExceptionsHandler

    resources :users

      desc 'Get all users'
      get "users" do
        authenticate_user!
        @current_user
      end

      desc 'user sign in'
      params do
        requires :user_name, type: String, desc: 'User Name'
        requires :password, type: String, desc: 'Password'
      end
      post "/users/sign_in" do
        user = User.find_by(user_name: params["user_name"])
        if user&.valid_password?(params[:password])
          expire_time = Time.now + 30.hours
          access_token = JsonWebToken.encode(user_id: user.id, exp: expire_time.to_i)
          return {
            access_token: access_token,
            user_id: user.id
          }
        else
          error!('Invalid user_name or password', 401)
        end
      end

      desc 'user sign up'
      params do
        requires :user_name, type: String, desc: 'User Name'
        requires :display_name, type: String, desc: 'Display Name'
        requires :password, type: String, desc: 'Password'
        requires :password_confirmation, type: String, desc: "Should Match the Password"
      end
      post "/users/sign_up" do
        user = User.create!(
          user_name: params["user_name"],
          display_name: params["display_name"],
          password: params["password"],
          password_confirmation: params["password_confirmation"]
        )
        expire_time = Time.now + 30.minutes
        access_token = JsonWebToken.encode(user_id: user.id, exp: expire_time.to_i)
        return {
          access_token: access_token,
          user_id: user.id
        }
      end

      desc "user Log out"
      get "/users/logout" do
        # write a way to remove the token in client
      end

      desc "user edit profile"
      params do
        requires :user_name, type: String, desc: 'User Name'
        requires :display_name, type: String, desc: 'Display Name'
        requires :password, type: String, desc: 'Password'
      end
      put "/users" do
        authenticate_user!
        if @current_user.valid_password?(params["password"])
          @current_user.update!(
            user_name: params["user_name"],
            display_name: params["display_name"],
            password: params["password"]
          )
          if params["new_password"].length > 0
            if params["new_password"] == params["new_password_confirmation"]
              @current_user.update!(
                  password: params["new_password"]
                )
              else
                error!("Validation failed: Password confirmation doesn't match Password", 400)
            end
          else
            puts '_'*100
            puts "No password change"
            puts '_'*100
          end
        else
          error!('Invalid password', 401)
        end
        expire_time = Time.now + 30.minutes
        access_token = JsonWebToken.encode(user_id: @current_user.id, exp: expire_time.to_i)
        return {
          access_token: access_token,
          user_id: @current_user.id
        }
      end

      desc "remove account"
      params do
        requires :user_name, type: String, desc: 'User Name'
        requires :password, type: String, desc: 'Password'
      end
      delete "/users" do
        authenticate_user!
        if @current_user.valid_password?(params["password"])
          @current_user.destroy
        else
          error!('Invalid password', 401)
        end
      end
  end
end
