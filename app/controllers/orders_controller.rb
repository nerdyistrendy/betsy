class OrdersController < ApplicationController
  before_action :require_login, only: [:show]
  before_action :get_order, only: [:show]
  
  def cart
    @session = session
  end

  def show
    # require_login controller filter: only authorized merchant can view
    if @order
      if @order.order_include_merchant(@login_merchant)    # order includes products from @login_merchant 
        @items_from_merchant = @order.order_include_merchant(@login_merchant)
        return
      else                                                 # order does NOT include product from @login_merchant 
        flash[:warning] = "You are not authorized to view this section"
        redirect_back(fallback_location: root_path)
        return
      end
    else
      flash[:warning] = "Invalid Order"
      redirect_back(fallback_location: root_path)
      return
    end
  end

  private

  def get_order
    return @order = Order.find_by(id: params[:id])
  end
end
