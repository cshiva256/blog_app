Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  #API "path", to: "folder#file", as: :url_alias (blogs_path(1) => "/blogs/1")
  devise_for :users
  get "/blogs/view" , to: "blogs#view", as: :blogs_view
  resources :blogs

  root "blogs#index"

  # for api
  mount Blogs::Api => "/"
  mount Users::Api => "/"
end
