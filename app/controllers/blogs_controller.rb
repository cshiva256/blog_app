class BlogsController < ApplicationController

  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_blog, only: [:show, :edit, :update, :destroy]

  def index
    @blogs = Blog.where(is_public: true).order(:created_at).reverse
    if params[:search]  # checks for nil value
      key = params[:search].strip
      if key.length>0
        @blogs.select! do |blog|
          blog.title.include?(key) or blog.content.to_plain_text.include?(key)
        end
      else
        redirect_to root_path, alert: "Enter text for performing search!!"
      end
    end
    # render json: @blogs
  end

  # to view private blogs
  def view
    @blogs = Blog.where(user_id: current_user[:id]).order(:created_at).reverse
    if params[:search]  # checks for nil value
      key = params[:search].strip
      if key.length>0
        @blogs.select! do |blog|
          blog.title.include?(key) or blog.content.to_plain_text.include?(key)
        end
      else
        redirect_to blogs_view_path, alert: "Enter text for performing search!!"
      end
    end
  end

  def show
    # @blog = Blog.find(params[:id])
    if !@blog[:is_public]
      if current_user.nil? or current_user[:id]!=@blog[:user_id]
        redirect_to blogs_path, alert: "You don't have access to this blog!!"
      end
    end
  end

  def new
    # create a object in memo and pass it to html to fill
    @blog = current_user.blogs.build
  end

  def edit
    # @blog = Blog.find(params[:id])
    if current_user[:id]!=@blog[:user_id]
      redirect_to blog_path, alert: "You dont have permission to modify this blog!!"
    end
  end

  def create
    @blog = current_user.blogs.build(blog_params)
    if @blog.save
      redirect_to @blog
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    # @blog = Blog.find(params[:id])
    if current_user[:id]==@blog[:user_id] and @blog.update(blog_params)
      redirect_to @blog
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # @blog = Blog.find(params[:id])
    msg = "You dont have permission to Delete this blog!!"
    if current_user[:id]==@blog[:user_id]
      @blog.destroy
      msg = "Succefully Deleted the Blog"
    end
    redirect_to blogs_path, notice: msg
  end

  private

  def blog_params
    # check if the params has the following data
    params.require(:blog).permit(:title, :content, :is_public)
  end

  def set_blog
      @blog = Blog.find(params[:id])
    rescue
      redirect_to blogs_path
  end

end