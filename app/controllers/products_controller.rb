class ProductsController < ApplicationController
  before_action :get_product, except: [:index, :new, :create]

  def show
    if @product.nil?
      flash[:error] = "Unvalid Product ID"
      redirect_to root_path
      return
    end
  end

  def new
    @product = Product.new
  end

  def create

  end

  private

  def product_params
    return params.require(:product).permit(:name, :inventory, :price, :description, :img_url, :merchant_id)
  end

  def get_product
    return @product = Product.find_by(id: params[:id])
  end
end
