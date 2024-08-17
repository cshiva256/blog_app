module Blogs
  class Api < Grape::API
    prefix :api
    format :json

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

      desc 'Show a Blog.'
      params do
        requires :id, type: Integer, desc: 'Blog ID.'
      end
      route_param :id do
        get do
          Blog.find(params[:id])
        end
      end

      desc 'Create a blog.'
      params do
        requires :title, type: String, desc: 'Blog Title'
        requires :content, type: String, desc: 'Blog content'
        requires :title, type: String, desc: 'Blog Accessibility'
      end
      post do
        # authenticate! (change the user_id later)
        Blog.create!({
          title: params[:title],
          content: params[:content],
          is_public: params[:is_public],
          user_id: 20
        })
      end

      desc 'Update a Blog.'
      params do
        requires :title, type: String, desc: 'Blog Title'
        requires :content, type: String, desc: 'Blog content'
        requires :title, type: String, desc: 'Blog Accessibility'
      end
      put ':id' do
        # authenticate!
        Blog.find(params[:id]).update({
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
        # authenticate!
        Blog.find(params[:id]).destroy
      end

      desc 'View private blogs'
      get :view do
        blogs = Blog.where(user_id: 20).order(:created_at).reverse
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