class Merchant < ApplicationRecord 
  has_many :order_items
  has_many :products
  has_many :orders


  def self.build_from_github(auth_hash)
    merchant = Merchant.new
    merchant.username = auth_hash["info"]["nickname"]
    merchant.email = auth_hash["info"]["email"]

    # The user is not saved here. Validate and save in controller.
    return merchant
  end

  def active_products
    return self.products.where(active: true)
  end
end
