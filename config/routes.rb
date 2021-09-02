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
    collection do
      get "get_region_countries", defaults: { format: "json" }
    end
  end
  resources :relationships, only: [:create, :destroy]
  get :login, to: "sessions#new"
  post :login, to: "sessions#create"
  post "guest_login", to: "guest_sessions#create"
  delete :logout, to: "sessions#destroy"
  get :favorites, to: "favorites#index"
  post "favorites/:destination_id/create" => "favorites#create"
  delete "favorites/:destination_id/destroy" => "favorites#destroy"
  resources :comments, only: [:create, :destroy]
  resources :notifications, only: :index
end
