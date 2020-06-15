class Order < ApplicationRecord
  has_many :order_items

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
