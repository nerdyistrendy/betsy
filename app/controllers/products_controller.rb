class ProductsController < ApplicationController
  # skip_before_action :require_login, only: [:index, :show]
  before_action :get_product, except: [:index, :new, :create, :cart]
  
  def index
    if params[:merchant_id]
      merchant = Merchant.find_by(id: params[:merchant_id])
      @products = merchant.products
    elsif params[:category_id]
      category = Category.find_by(id: params[:category_id])
      @products = category.products.uniq
    else
      @products = Product.all
    end
  end

  def show
    if @product.nil?
      flash[:error] = "Unvalid Product ID"
      redirect_to products_path, status: :not_found
      return
    end
  end

  def new
    default_img = "https://lh3.googleusercontent.com/pw/ACtC-3eMhEM2kaTc-RlRyVudYKP08KOdRO6QbvXTc_PkmzKzXTIkCqRDIa06GMT1FaJr-lDgIcjmnR5hEEFOCYf4YUDKfozbnOhaOw02IpXMOTr2LW4L2S2PXJfedaWYHq6uTewLUuufgMD0VBs_xdtE7FUy=w1350-h900-no?authuser=0"
    if params[:merchant_id]
    # This is the nested route, /merchant/:merchant_id/products/new
      @categories = Category.all.order("name DESC")
      @product = Product.new
      @product.img_url = default_img
      @product.price = "0.00"
      @product.inventory = 0
    else
    # non-merchants cannot create products
      flash[:error] = "You must login to do that"
      redirect_to products_path
    end
  end

  def create
    # if session[:user_id]
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
    # else
    #   flash.now[:error] = "You must be logged in to do that"
    #   render :new, status: :bad_request
    #   return
    # end
  end

  def cart
    @session = session
    @session[:cart] ||= {}
    @product = Product.find_by(id: params[:product_id])
    
    if @product.inventory > 0
      @session[:cart]["#{@product.id}"] = params[:quantity]
      flash.now[:success] = "Product successfully added to your cart"
      render :show
      return
    else
      flash.now[:error] = "Sorry, this product is currently out of stock!"
      render :show
      return
    end
  end

  private

  def product_params
    return params.require(:product).permit(:name, :inventory, :price, :description, :img_url, :merchant_id, category_ids: [])
  end

  def get_product
    return @product = Product.find_by(id: params[:id])
  end

  
end
