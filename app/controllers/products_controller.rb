class ProductsController < ApplicationController
  before_action :get_product, except: [:index, :new, :create]

  def show
    if @product.nil?
      flash[:error] = "Unvalid Product ID"
      redirect_to products_path, status: :not_found
      return
    end
  end

  def new
    if params[:merchant_id]
    # This is the nested route, /merchant/:merchant_id/products/new
      @categories = Category.all.order("name DESC")
      @product = Product.new(merchant_id: params[:merchant_id])
      @product.img_url = "default.jpg"
      @product.price = "0.00"
      @product.inventory = 0
    else
    # non-merchants cannot create products
      flash[:error] = "You must login to do that"
      redirect_to products_path
    end
  end

  def create
    if params[:merchant_id]
      @product = Product.new(product_params)
      @product.active = true
      @product.merchant_id = params[:merchant_id]

      if @product.save
        flash[:success] = "Successfully added product: #{@product.name}"
        redirect_to product_path(@product.id)
        return
      else
        flash.now[:error] = "Unable to add product"
        render :new, status: :bad_request
        return
      end
    else
      flash.now[:error] = "You must be logged in to do that"
      render :new, status: :bad_request
      return
    end
  end

  private

  def product_params
    return params.require(:product).permit(:name, :inventory, :price, :description, :img_url, category_ids: [])
  end

  def get_product
    return @product = Product.find_by(id: params[:id])
  end
end
