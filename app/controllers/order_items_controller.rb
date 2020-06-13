class OrderItemsController < ApplicationController

  TODO: Finish this method 
  def index
    @merchant_orders = Order.where(merchant_id: params[:merchant_id])
  end 

end
