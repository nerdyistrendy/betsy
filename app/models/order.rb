class Order < ApplicationRecord
  has_many :order_items
  validates :name, :email, :mailing_address, :cc_name, :cc_cvv, :cc_exp, :cc_number, :zipcode, :status, presence: true
  validates :email, format: { with: /\w+@\w+\.\w+/, message: "Please enter valid email address" }
  validates :cc_cvv, :cc_number, :zipcode, numericality: { only_integer: true }
  validates :cc_number, length: {is: 16}
  validates :cc_cvv, length: {is: 3}
  validates :zipcode, length: {is: 5}
  validates :status, inclusion: { in: %w(pending paid complete cancelled) }


  def order_total
    total = 0
    self.order_items.each do |order_item|
      price = order_item.product.price
      total += price * order_item.quantity
    end
    return (total * 1.1)
  end
  
  # if order instance includes order_items from this merchant
  def order_include_merchant(merchant)
    items_from_merchant = self.order_items.where(merchant_id: merchant.id)

    if items_from_merchant.empty?
      return false
    else
      return items_from_merchant
    end
  end
end
