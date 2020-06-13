class Merchant < ApplicationRecord 
  has_many :order_items
  has_many :products
  has_many :orders

end
