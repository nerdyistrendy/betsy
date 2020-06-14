class OrdersController < ApplicationController

  def cart
    @session = session
  end

  def new
    @order = Order.new
  end

  def create
  end

end
