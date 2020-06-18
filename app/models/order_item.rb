class OrderItem < ApplicationRecord
  belongs_to :merchant
  belongs_to :product
  belongs_to :order

  def subtotal
    product = Product.find_by(id: self.product_id)
    if self.quantity && product
      return (self.quantity * product.price).to_f.round(2)
    end
  end

  def self.filter_merchant_status(merchant: nil, status: nil)
    return [] if merchant.nil?
    if status
      return OrderItem.where(merchant_id: merchant.id, status: status)
    else
      return OrderItem.where(merchant_id: merchant.id)
    end
  end
end
