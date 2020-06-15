class OrdersController < ApplicationController
  before_action :require_login, only: [:show]
  before_action :get_order, only: [:show]
  before_action :order_include_merchant, only: [:show]
  
  def cart
    @session = session
  end

  def show
    # require_login controller filter
    # order_include_merchant controller filter: checking if the merchant is authorized to view this page
    if !@order
      flash[:warning] = "Invalid Order"
      redirect_to root_path
    end
  end

  private

  def get_order
    return @order = Order.find_by(id: params[:id])
  end

  # might need to break into 1 model method and 1 controller filter.....
  def order_include_merchant
   
    # @items_from_merchant = @order.order_items.where(merchant_id: @login_merchant.id)

    @items_from_merchant = []

    if @order
      @order.order_items.each do |item|
        @items_from_merchant << item if item.merchant_id == @login_merchant.id
      end

      if @items_from_merchant.empty?
        flash[:warning] = "You are not authorized to view this section"
        redirect_to root_path
        return false
      else
        return @items_from_merchant
      end
    end
  end
end
