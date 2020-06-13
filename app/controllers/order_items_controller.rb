class OrderItemsController < ApplicationController

  def index
    @merchant_order_items = OrderItem.where(merchant_id: params[:merchant_id])
  end 
end
