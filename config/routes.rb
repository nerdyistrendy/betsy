Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "/auth/github", as: "github_login"
  get "/auth/:provider/callback", to: "merchants#create"

  get "orders/cart", to: 'orders#cart', as: "cart"
  post "orders/:id/cancel", to: 'orders#cancel', as: "cancel_order"
  delete "order_items/:id/cancel", to: 'order_items#cancel', as: "cancel_item"
  post "products/:id/active", to: 'products#toggle_active', as: "toggle_active"
  post "order_items/:id/ship", to: 'order_items#ship', as: "ship_item"


  resources :products do
    resources :reviews, only: [:new, :create]
  end

  resources :merchants, only: [:index, :show] do
    resources :products, only: [:index]
    resources :order_items, only: [:index]
    resources :orders, only: [:index, :show]
  end

  resources :orders, only: [:show, :new, :create]

  resources :order_items, only: [:create, :edit, :update, :destroy]

  resources :categories, only: [:new, :create]  
end
