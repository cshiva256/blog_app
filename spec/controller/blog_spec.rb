# server side testing
require 'rails_helper'
require 'devise'

RSpec.describe BlogsController, type: :controller do

  include Devise::Test::ControllerHelpers

  let(:user) { User.create!(
      user_name: 'user1',
      display_name: 'User 1',
      password: 'password'
    )}

  let(:user2) { User.create!(
      user_name: 'user2',
      display_name: 'User 2',
      # look for this failure error
      email: 'tmp@gmail.com',
      password: 'password'
  )}

  let(:public_blog) { Blog.create(
      title:"Public Test Blog",
      content: "This is a public test blog",
      is_public: true,
      user_id: user.id
    )}

    let(:private_blog) { Blog.create(
      title:"Private Test Blog",
      content: "This is a private test blog",
      is_public: false,
      user_id: user.id
    )}

  let(:search_blog) { Blog.create(
      title:"Search Test Blog",
      content: "This is a search test blog",
      is_public: true,
      user_id: user.id
    )}

  before do
  end

  describe 'GET#index' do
    it 'assigns all user blogs as @blogs' do
      public_blog
      private_blog
      get :index
      expect(assigns(:blogs)).to eq([public_blog])
      expect(assigns(:blogs)).not_to include(private_blog)
    end

    it 'renders the index' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'renders the index with search' do
      public_blog
      get :index , params: {search: "Test"}
      expect(response).to render_template(:index)
    end

    it 'renders the index with search empty string' do
      public_blog
      get :index , params: {search: ""}
      expect(response).to redirect_to(:root)
    end
  end

  describe 'GET#view' do
    before do
      sign_in user
    end

    it 'assigns private blogs as @blogs' do
      private_blog
      public_blog
      get :view
      expect(assigns(:blogs)).to include(private_blog)
      expect(assigns(:blogs)).to include(public_blog)
    end

    it 'renders my blogs(view)' do
      get :view
      expect(response).to render_template(:view)
    end

    it 'renders my blogs(view), with search' do
      public_blog
      get :view, params: {search: "Test"}
      expect(response).to render_template(:view)
    end

    it 'renders my blogs(view), with search as empty string' do
      public_blog
      get :view, params: {search: ""}
      expect(response).to redirect_to(:blogs_view)
    end
  end

  describe 'GET#show' do
    it 'public blog and no User' do
      get :show, params: {id: public_blog.id}
      expect(response).to render_template(:show)
    end

    it 'private blog and no User' do
      get :show, params: {id: private_blog.id}
      expect(response).to redirect_to(:blogs)
    end

    it 'private blog and User' do
      sign_in user
      get :show, params: {id: private_blog.id}
      expect(response).to render_template(:show)
    end

    it 'private blog and other User' do
      sign_in user2
      get :show, params: {id: private_blog.id}
      expect(response).to redirect_to(:blogs)
    end

    it 'invalid blog' do
      get :show, params: {id: 100}
      expect(response).to redirect_to(:blogs)
    end
   end

  describe 'GET#new' do
    it 'renders the new' do
      sign_in user
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'GET#edit' do
    it 'renders the edit valid user' do
      sign_in user
      get :edit, params: {id: public_blog.id}
      expect(response).to render_template(:edit)
    end

    it 'renders the edit invalid user' do
      sign_in user2
      get :edit, params: {id: public_blog.id}
      expect(response).to redirect_to(:blog)
    end
  end

  describe 'POST#create' do
    before do
      sign_in user
    end
    context 'with valid params' do
      let(:valid_attributes) {
        {
          title: 'Test blog', content: 'Test blog content',
          is_public: true
        }
      }
      it 'creates a new blog' do
        expect {
          post :create, params: {blog: valid_attributes}
        }.to change(Blog, :count).by(1)
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) {
        {
          title: '', content: 'Test blog content',
          is_public: true
        }
      }
      it 'error while creating a new blog' do
        post :create, params: {blog: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT#update' do
    context 'with valid params' do
      let(:new_attributes) {
        {title: 'New Title'}
      }
      it 'updates the requested blog' do
        sign_in user
        put :update, params: {id: public_blog.id, blog: new_attributes}
        public_blog.reload
        expect(public_blog[:title]).to eq('New Title')
      end

      it 'update by unauthorized user' do
        sign_in user2
        put :update, params: {id: public_blog.id, blog: new_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) {
        {title: ''}
      }
      it 'error while updating the blog' do
        sign_in user
        put :update, params: {id: public_blog.id, blog: invalid_attributes}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE#destroy' do
    it 'destroys the requested blog' do
      sign_in user
      public_blog
      expect {
        delete :destroy, params: {id: public_blog.id}
      }.to change(Blog, :count).by(-1)
    end

    it 'destroy by unauthorized user' do
      sign_in user2
      public_blog
      delete :destroy, params: {id: public_blog.id}
      expect(response).to have_http_status(:found)
    end
  end
end
