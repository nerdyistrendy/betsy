class OrderItemsController < ApplicationController

  before_action :require_login, only: [:index]

  def index
    if params[:merchant_id].to_i != @login_merchant.id
      flash[:warning] = "You are not authorized to view this section"
      redirect_back(fallback_location: root_path)
      return
    end

    # Adding Query String for filtered views: https://stackoverflow.com/questions/2695538/add-querystring-parameters-to-link-to
    @status = params["status"]
    if @status == "pending"
      @merchant_order_items = OrderItem.where(merchant_id: params[:merchant_id], status: "pending")
      return
    elsif @status == "shipped"
      @merchant_order_items = OrderItem.where(merchant_id: params[:merchant_id], status: "shipped")
      return
    else
      @status = "all"
      @merchant_order_items = OrderItem.where(merchant_id: params[:merchant_id])
      return
    end

    # I think we can still render this view that shows 0 order items?
    # if @merchant_order_items == nil
    #   flash[:error] = "Merchant does not have order items in our database."
    #   head :not_found
    # end
  end 
  

  #Another bit of code relies on this, so feel free to alter it, but please don't delete it. 
  def show
  end
end
