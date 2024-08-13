Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  #API "path", to: "folder#file", as: :url_alias (blogs_path(1) => "/blogs/1")
  devise_for :users
  # resources :users, only: [:show]
  resources :blogs

  root "blogs#index"
end
