class OrderItemsController < ApplicationController

  def index
    @merchant_order_items = OrderItem.where(merchant_id: params[:merchant_id])

    if @merchant_order_items == nil
      flash[:error] = "Merchant does not have order items in our database."
      head :not_found
    end
  end 

  #Another bit of code relies on this, so feel free to alter it, but please don't delete it. 
  def show
  end

  
end
