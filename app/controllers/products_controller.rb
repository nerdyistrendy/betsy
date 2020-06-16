class ProductsController < ApplicationController
  before_action :require_login, only: [:new, :create, :toggle_active]
  before_action :get_product, except: [:index, :new, :create, :cart]
  before_action :get_merchant, only: [:index, :toggle_active, :create]
  before_action :get_category, only: [:index]

  def index
    if params[:merchant_id]
      if @merchant
        @products = @merchant.active_products
      else
        flash[:error] = "Invalid Merchant"
        redirect_to merchants_path
        return
      end
    elsif params[:category_id]
      if @category
        @products = @category.active_products.uniq
      else
        flash[:error] = "Invalid Category"
        redirect_to categories_path
        return
      end
    else
      @products = Product.active_products
    end
  end

  def show
    if @product.nil?
      flash[:error] = "Invalid Product"
      redirect_to products_path, status: :not_found
      return
    end
    @status = (@product.active ? "Retire Product" : "Reactivate Product")
    @reviews = @product.reviews
  end

  def new
    default_img = "https://lh3.googleusercontent.com/pw/ACtC-3eMhEM2kaTc-RlRyVudYKP08KOdRO6QbvXTc_PkmzKzXTIkCqRDIa06GMT1FaJr-lDgIcjmnR5hEEFOCYf4YUDKfozbnOhaOw02IpXMOTr2LW4L2S2PXJfedaWYHq6uTewLUuufgMD0VBs_xdtE7FUy=w1350-h900-no?authuser=0"

    @categories = Category.all.order("name DESC")
    @product = Product.new
    @product.img_url = default_img
    @product.price = 0.00
    @product.inventory = 0
  end

  def create
    @product = Product.new(product_params)
    @product.active = true
    @product.merchant_id = @login_merchant.id

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

  def edit
    @product = Product.find_by(id: params[:id])

    if @product == nil
      flash[:error] = "Cannot edit a non-existent product."
      redirect_to merchant_products_path(@product.id)
    elsif @product.merchant_id != session[:user_id]
      flash[:error] = "You are not authorized to edit that product."
      redirect_to merchant_products_path(@product.id)
    end 
  end 

  def update
    @product = Product.find_by(id: params[:id])

    if @product.update(product_params)
      flash[:success] = "Product successfully updated."
    else
      flash[:error] = "Product could not be updated."
    end

    redirect_to merchant_path(session[:user_id])
  end 

  def destroy
    @product = Product.find_by(id: params[:id])
    @merchant = Merchant.find_by(id: @product.merchant_id)

    if @product.destroy
      flash[:success] = "Product successfully deleted."
    else
      flash[:error] = "Product could not be deleted."
    end 
  
    redirect_to merchant_products_path(@merchant.id)
  end

  def cart
    @product = Product.find_by(id: params[:product_id])
    @quantity = params[:quantity]
    if @product.inventory > 0 && @quantity.to_i <= @product.inventory
      session[:cart]["#{@product.id}"] = @quantity
      flash.now[:success] = "Product successfully added to your cart"
      render :show
      return
    else
      if @product.inventory == 0
        flash.now[:error] = "Sorry, this product is currently out of stock!"
        render :show
        return
      elsif @quantity.to_i >= @product.inventory
        flash.now[:error] = "Quantity requested is larger that product inventory"
        render :show
        return
      end
    end
  end

  def update_quant
    @product = Product.find_by(id: params[:product_id])
    @quantity = params[:quantity]
    if @product.inventory > 0 && @quantity.to_i <= @product.inventory
      session[:cart]["#{@product.id}"] = @quantity
      redirect_to order_cart_path
      return
    else
      if @product.inventory == 0
        flash.now[:error] = "Sorry, this product is currently out of stock!"
        redirect_to order_cart_path
        return
      elsif @quantity.to_i >= @product.inventory
        flash.now[:error] = "Quantity requested is larger that product inventory"
        redirect_to order_cart_path
        return
      end
    end
  end

  def remove_from_cart
    session[:cart].delete(params[:id])
    redirect_to order_cart_path
    return
  end

  def toggle_active
    if @product
      current_state = @product.active
      if @login_merchant.id == @product.merchant_id
        @product.update!(active: !current_state)
        flash[:success] = "Product was successfully updated"
      else
        flash[:error] = "You cannot retire another merchant's product"
      end
      redirect_to product_path(@product.id)
    else
      flash[:error] = "Invalid Product"
      redirect_to root_path
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

  def get_merchant
    return @merchant = Merchant.find_by(id: params[:merchant_id])
  end

  def get_category
    return @category = Category.find_by(id: params[:category_id])
  end
end
