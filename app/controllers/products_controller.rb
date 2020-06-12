class ProductsController < ApplicationController
  before_action :get_product, except: [:index, :new, :create]

  def index
    @products = Product.all
  end

  def show
    if @product.nil?
      flash[:error] = "Unvalid Product ID"
      redirect_to root_path, status: :bad_request
      return
    end
  end
  
  private

  def product_params
    return params.require(:product).permit(:name, :inventory, :price, :description, :img_url, :merchant_id, categories: [])
  end

  def get_product
    return @product = Product.find_by(id: params[:id])
  end
end
