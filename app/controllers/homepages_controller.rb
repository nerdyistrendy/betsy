class HomepagesController < ApplicationController
  def index
    @products = Product.all
    @merchants = Merchant.all
    @categories = Category.all
  end
end
