class OrdersController < ApplicationController

  def cart
    @session = session
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
      @order.status = "paid"
      @cart.each do |item|
        @product = Product.find_by(id: item[0].to_i)
        @order_item = OrderItem.new(product_id: @product.id, 
          order_id: @order.id, quantity: item[1].to_i, 
          status: @order.status,
          merchant_id: @product.merchant.id
        )
        @order_item.save
        @product.inventory -= @order_item.quantity
        @product.save
        session[:cart].delete("#{item[0]}")
      end
    end

    if @order.valid? && @order.order_items.empty? == false
      @order.status = "paid"
      @order.save
      redirect_to order_cart_path
    else
      flash.now[:error] = "A problem while checking out. Please try again!" #{@work.category}"
      render :new, status: :bad_request
      return
    end
  end

  private

  def order_params
    return params.require(:order).permit(:name, :email, :mailing_address, :cc_name, :cc_cvv, :cc_exp, :cc_number, :zipcode, :status)
  end

end
