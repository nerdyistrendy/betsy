class OrdersController < ApplicationController

  def show
    @orders = Order.find_by(merchant_id: params[:merchant_id])
  end
end
