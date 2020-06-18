class OrderItemsController < ApplicationController

  before_action :require_login, only: [:ship, :cancel, :fulfillment]
  before_action :get_orderitem

  def fulfillment
    # Adding Query String for filtered views: https://stackoverflow.com/questions/2695538/add-querystring-parameters-to-link-to
    @status = params["status"]
    if @status == "pending"
      @merchant_order_items = OrderItem.filter_merchant_status(merchant: @login_merchant, status: "pending")
      return
    elsif @status == "shipped"
      @merchant_order_items = OrderItem.filter_merchant_status(merchant: @login_merchant, status: "shipped")
      return
    else
      @status = "all"
      @merchant_order_items = OrderItem.filter_merchant_status(merchant: @login_merchant)
      return
    end
  end 

  
  def ship
    if @orderitem && @orderitem.merchant_id == @login_merchant.id
      if @orderitem.status == "shipped"
        flash[:warning] = "This order item was previously shipped"
        redirect_back(fallback_location: root_path)
        return
      elsif @orderitem.status == "cancelled"
        flash[:warning] = "Unable to ship a cancelled item"
        redirect_back(fallback_location: root_path)
        return
      else
        @orderitem.update(status: "shipped")
        order = Order.find_by(id: @orderitem.order_id)
        order.mark_order_complete
        flash[:success] = "Successfully Shipped"
        redirect_back(fallback_location: root_path)
        return
      end
    else
      flash[:warning] = "Invalid Order Item"
      redirect_back(fallback_location: root_path)
      return
    end
  end


  def cancel
    if @orderitem && @orderitem.merchant_id == @login_merchant.id
      if @orderitem.status == "shipped"
        flash[:warning] = "Unable to cancel a shipped item"
        redirect_back(fallback_location: root_path)
        return
      elsif @orderitem.status == "cancelled"
        flash[:warning] = "This order item was previously cancelled"
        redirect_back(fallback_location: root_path)
        return
      else
        @orderitem.update(status: "cancelled")
        flash[:success] = "Successfully Cancelled"
        order = Order.find_by(id: @orderitem.order_id)
        order.mark_order_complete
        redirect_back(fallback_location: root_path)
        return
      end
    else
      flash[:warning] = "Invalid Order Item"
      redirect_back(fallback_location: root_path)
      return
    end
  end

  private

  def get_orderitem
    return @orderitem = OrderItem.find_by(id: params[:id])
  end
end
