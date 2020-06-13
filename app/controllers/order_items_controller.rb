class OrderItemsController < ApplicationController

  def index
    puts params
    @orders = Orders.find_by(merchant_id: params[:merchant_id])

    @merchant = Merchant.find_by(id: params[:id])
    @orders = Order.where(merchant_id: params[:merchant_id])

    # if params[:merchant_id].nil?
    #   @orders = Order.all
    # else
    #   @passenger = Passenger.find_by(id: params[:passenger_id])
    #   @trips = Trip.where(passenger_id: params[:passenger_id])
    # end
  end 

end
