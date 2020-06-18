Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "homepages#index"
  
  get "/auth/github", as: "github_login"
  get "/auth/:provider/callback", to: "merchants#create", as: "oauth_callback"
  post "/logout", to: "merchants#logout", as: "logout"
  
  get "/dashboard", to: "merchants#dashboard", as: "dashboard"
  get "/order_fulfillments", to: "order_items#fulfillment", as: "fulfillment"
  get "orders/lookup", to: "orders#lookup", as: "order_lookup"
  get "orders/find", to: "orders#find", as: "find_order"
  get "orders/cart", to: "orders#cart", as: "order_cart"
  delete "orders/:id/cancel", to: "orders#cancel", as: "cancel_order"
  delete "order_items/:id/cancel", to: "order_items#cancel", as: "cancel_item"
  patch "products/:id/active", to: "products#toggle_active", as: "toggle_active"
  patch "order_items/:id/ship", to: "order_items#ship", as: "ship_item"

  resources :products, except: [:new] do
    resources :reviews, only: [:new, :create]
    patch "/cart", to: "products#cart", as: "cart"
    patch "cart/update", to: "products#update_quant", as: "update_quant"
    patch "/remove", to: "products#remove_from_cart", as: "remove_cart"
  end

  resources :merchants, only: [:index, :show] do
    resources :products, except: [:show, :edit]
    resources :order_items, only: [:index]
    resources :orders, only: [:index, :show]
  end

  resources :orders, only: [:show, :new, :create] do
    get "/confirmation", to: "orders#confirmation", as: "confirmation"
  end

  resources :order_items, only: [:edit, :update, :destroy]

  resources :categories, only: [:new, :create, :index] do
    resources :products, only: [:index]
  end
end
