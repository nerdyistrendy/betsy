class MerchantsController < ApplicationController

  def show
    @merchant = Merchant.find_by(id: params[:id])
    if @merchant == nil
      flash[:error] = "Merchant does not exist in our database." 
      head :not_found
      return
    end 

    @orders = @merchant.orders 
  end 
end
