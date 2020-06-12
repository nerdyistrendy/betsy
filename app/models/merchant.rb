class Merchant < ApplicationRecord 
  has_many :order_items
  has_many :products
  has_many :orders
  
  def authorized? 
    # TODO: Add in functionality to check if merchant is logged in. RE: merchants/show.html.erb file
  end 
end
