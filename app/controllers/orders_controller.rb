class OrdersController < ApplicationController

  def cart
    @session = session
  end

  def new
    @order = Order.new
  end
end
