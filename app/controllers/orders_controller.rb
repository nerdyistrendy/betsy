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

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)
    @order.status = "pending"
    @cart = session[:cart]
    ActiveRecord::Base.transaction do
      @order.save
      @cart.each do |item|
        @product = Product.find_by(id: item[0].to_i)
        @order_item = OrderItem.new(product_id: @product.id, 
          order_id: @order.id, quantity: item[1].to_i, 
          status: "pending",
          merchant_id: @product.merchant.id
        )
        @order_item.save
        @product.decrease_inventory(@order_item.quantity)
        session[:cart].delete("#{item[0]}")
      end
    end

    if @order.valid? && @order.order_items.empty? == false
      @order.status = "paid"
      @order.save
      redirect_to order_confirmation_path(@order.id)
      return
    else
      flash.now[:error] = "A problem while checking out. Please try again!" 
      render :new, status: :bad_request
      return
    end
  end

  def confirmation
    @order = Order.find_by(id: params[:order_id])
    if @order.nil?
      flash.now[:error] = "There was a problem retrieving your order. Please try again!" 
      redirect_to root_path, status: :bad_request
  end
    
  private


  def order_params
    return params.require(:order).permit(:name, :email, :mailing_address, :cc_name, :cc_cvv, :cc_exp, :cc_number, :zipcode, :status)
  end

  def get_order
    return @order = Order.find_by(id: params[:id])
  end
end