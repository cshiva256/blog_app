class BlogsController < ApplicationController

  before_action :authenticate_user!, except: [:index]
  before_action :set_blog, only: [:show, :edit, :update, :destroy]

  def index
    if user_signed_in?
      @blogs = Blog.where(user_id: current_user[:id]).or(Blog.where(is_public: true))
      if params[:search]  # checks for nil value
        if params[:search].length>0
          puts "-"*100
          puts params
          puts "-"*100
          key = params[:search].strip
          @blogs = @blogs.select do |blog|
            blog.title.include?(key) or blog.content.to_plain_text.include?(key)
          end
        else
          redirect_to root_path, alert: "Enter text for performing search!!"
        end
      end
    else
      @blogs = Blog.where(is_public: true)
    end

    @blogs = @blogs.sort_by(&:created_at).reverse
    # render json: @blogs
  end

  def show
    # @blog = Blog.find(params[:id])
    if !@blog[:is_public] and current_user[:id]!=@blog[:user_id]
      redirect_to blogs_path
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