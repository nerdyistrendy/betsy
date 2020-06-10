class RelateMerchantToOrderItems < ActiveRecord::Migration[6.0]
  def change
    add_reference :order_items, :merchant, index: true
  end
end
