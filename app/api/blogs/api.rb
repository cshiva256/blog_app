module Blogs
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

      def validate_user!
        @blog = Blog.find(params[:id])
        if @current_user[:id]!=@blog[:user_id]
          error!('Not Valid User', 403)
        end
      end
    end

    include ExceptionsHandler

    resource :blogs do

      desc 'Go the home page (Public blogs)'
      get do
        blogs = Blog.where(is_public: true).order(:created_at).reverse
        if params[:search]  # checks for nil value
          key = params[:search].strip
          if key.length>0
            blogs.select! do |blog|
              blog.title.include?(key) or blog.content.to_plain_text.include?(key)
            end
          end
        end
        blogs.map do |blog|
          {
            id: blog.id,
            title: blog.title,
            content: blog.content[:body].to_plain_text.truncate(30)+"...",
            display_name: blog.user[:display_name]
          }
        end
      end

      desc 'Show a Blog.'
      params do
        requires :id, type: Integer, desc: 'Blog ID.'
      end
      route_param :id do
        get do
          blog = Blog.find(params[:id])
          if !blog[:is_public]
            if (authenticate_user! and @current_user[:id]!=blog[:user_id])
              error!('Not Valid User', 403) # forbidden
            end
          end
          return {
            id: blog.id,
            title: blog.title,
            content: blog.content[:body].to_plain_text,
            display_name: blog.user[:display_name],
            is_public: blog.is_public,
            user_id: blog.user[:id]
          }
        end
      end

      desc 'Create a blog.'
      params do
        requires :title, type: String, desc: 'Blog Title'
        requires :content, type: String, desc: 'Blog content'
        requires :is_public, type: Boolean, desc: 'Blog Accessibility'
      end
      post do
        authenticate_user!
        Blog.create!({
          title: params[:title],
          content: params[:content],
          is_public: params[:is_public],
          user_id: @current_user[:id]
        })
      end

      desc 'Update a Blog.'
      params do
        requires :title, type: String, desc: 'Blog Title'
        requires :content, type: String, desc: 'Blog content'
        requires :is_public, type: Boolean, desc: 'Blog Accessibility'
      end
      put ':id' do
        authenticate_user!
        validate_user!
        @blog.update({
          title: params[:title],
          content: params[:content],
          is_public: params[:is_public]
        })
      end

      desc 'Delete a Blog.'
      params do
        requires :id, type: String, desc: 'Blog ID.'
      end
      delete ':id' do
        authenticate_user!
        validate_user!
        @blog.destroy
      end

      desc 'View private blogs'
      get :view do
        authenticate_user!
        blogs = Blog.where(user_id: @current_user[:id]).order(:created_at).reverse
        if params[:search]  # checks for nil value
          key = params[:search].strip
          if key.length>0
            blogs.select! do |blog|
              blog.title.include?(key) or blog.content.to_plain_text.include?(key)
            end
          else
            redirect_to root_path, alert: "Enter text for performing search!!"
          end
        end
        blogs.map do |blog|
          {
            id: blog.id,
            title: blog.title,
            content: blog.content[:body].to_plain_text.truncate(30),
            display_name: blog.user[:display_name]
          }
        end
      end

    end
  end
end