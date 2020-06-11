Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "/auth/github", as: "github_login"
  get "/auth/:provider/callback", to: "merchants#create"
  post "/logout", to: "merchants#logout", as: "logout"
  
  get "orders/lookup", to: "orders#lookup", as: "order_lookup"
  get "orders/cart", to: "orders#cart", as: "cart"
  delete "orders/:id/cancel", to: "orders#cancel", as: "cancel_order"
  delete "order_items/:id/cancel", to: "order_items#cancel", as: "cancel_item"
  patch "products/:id/active", to: "products#toggle_active", as: "toggle_active"
  patch "order_items/:id/ship", to: "order_items#ship", as: "ship_item"


  resources :products, except: [:new, :create] do
    resources :reviews, only: [:new, :create]
  end

  resources :merchants, only: [:index, :show] do
    resources :products, only: [:index, :new, :create]
    resources :order_items, only: [:index]
  end

  resources :orders, only: [:show, :new, :create]

  resources :order_items, only: [:create, :edit, :update, :destroy]

  resources :categories, only: [:new, :create]  
end
