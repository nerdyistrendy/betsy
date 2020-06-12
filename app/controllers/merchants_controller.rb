class MerchantsController < ApplicationController

  def show
    @merchant = Merchant.find_by(id: params[:id])
    @orders = @merchant.orders 

    if @merchant == nil
      flash[:error] = "Merchant does not exist in our database." 
      redirect_to root_path
      return
    end 
  end 
end
