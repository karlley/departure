Rails.application.routes.draw do
  root "static_pages#home"
  get :about, to: "static_pages#about"
  get :signup, to: "users#new"
  resources :users do
    member do
      get :following, :followers
    end
  end
  resources :destinations do
    # new Ajax /destinations/get_region_countries
    collection do
      get "get_region_countries", defaults: { format: "json" }
    end
    # edit Ajax /destinations/:id/get_region_countries
    member do
      get "get_region_countries", defaults: { format: "json" }
    end
  end
  # create Ajax /get_region_countries
  get "get_region_countries", to: "destinations#get_region_countries", defaults: { format: "json" }
  resources :relationships, only: [:create, :destroy]
  get :login, to: "sessions#new"
  post :login, to: "sessions#create"
  post "guest_login", to: "guest_sessions#create"
  delete :logout, to: "sessions#destroy"
  get :favorites, to: "favorites#index"
  post "favorites/:destination_id/create", to: "favorites#create"
  delete "favorites/:destination_id/destroy", to: "favorites#destroy"
  resources :comments, only: [:create, :destroy]
  resources :notifications, only: :index
end
