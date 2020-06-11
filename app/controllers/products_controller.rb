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
    if params[:merchant_id]
    # This is the nested route, /merchant/:merchant_id/products/new
    merchant = Merchant.find_by(id: params[:merchant_id])
    @product = merchant.products.new
    else
    # non-merchants cannot create products
      flash[:error] = "You must login to do that"
      redirect_to root_path
    end
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      flash[:success] = "Successfully added product: #{@product.name}"
      redirect_to product_path(@product.id)
      return
    else
      flash.now[:error] = "Unable to add product"
      render :new, status: :bad_request
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
