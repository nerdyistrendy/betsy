class Merchant < ApplicationRecord 
  has_many :order_items
  has_many :products

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

  # model method in merchant that calculates  total revenue
  # model method in merchant that calculates  total revenue by status
  # model method in merchant that calculates  total number of orders by status
  def total_revenue(status = "all")
    revenue = 0.00

    if status == "all"
      self.order_items.each do |item|
        revenue += item.subtotal      #instance method in order_items
      end
    else
      self.order_items.where("status = ?", status).find_each do |item|
        revenue += item.subtotal
      end
    end

    if revenue > 0
      return revenue
    else
      return "No money made yet!"
    end
  end

  def count_orders(status = "all")
    if status == "all"
      return count = self.order_items.count
    else
      return count = self.order_items.where("status = ?", status).count
    end
  end
end
