class ProductsController < ApplicationController
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
  end

  def new
    default_img = "https://lh3.googleusercontent.com/pw/ACtC-3eMhEM2kaTc-RlRyVudYKP08KOdRO6QbvXTc_PkmzKzXTIkCqRDIa06GMT1FaJr-lDgIcjmnR5hEEFOCYf4YUDKfozbnOhaOw02IpXMOTr2LW4L2S2PXJfedaWYHq6uTewLUuufgMD0VBs_xdtE7FUy=w1350-h900-no?authuser=0"
    # if params[:merchant_id]
    # This is the nested route, /merchant/:merchant_id/products/new
      @categories = Category.all.order("name DESC")
      @product = Product.new
      @product.img_url = default_img
      @product.price = "0.00"
      @product.inventory = 0
    # else
    # # non-merchants cannot create products
    #   flash[:error] = "You must login to do that"
    #   redirect_to products_path
    # end
  end

  def create
    # if session[:user_id]
      @product = Product.new(product_params)
      @product.active = true
      @product.merchant_id = @merchant.id

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

  def edit
    @product = Product.find_by(id: params[:id])

    if @product.merchant_id != session[:user_id]
      flash[:error] = "You are not authorized to edit that product."
      redirect_to merchant_products_path(@product.id)
    elsif @product == nil
      flash[:error] = "Cannot edit a non-existent product."
      redirect_to merchant_products_path(@product.id)
    end 
  end 

  def update
    @product = Product.find_by(id: params[:id])

    if @product.update(@product.id)
      flash[:success] = "Product successfully updated."
    else
      flash[:error] = "Product could not be updated."
    end

    redirect_to merchant_products_path(@product.id)
  end 

  def destroy
    @product = Product.find_by(id: params[:id])

    @product.destroy
    if @product.destroy(@product.id)
      flash[:success] = "Product successfully deleted."
    else
      flash[:error] = "Product could not be deleted."
    end 
  
    redirect_to merchant_products_path(@merchant.name)
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
    current_state = @product.active

    if @product.update!(active: !current_state)
      flash[:success] = "Product was successfully updated"
      redirect_back fallback_location: products_path(@product.id)
      return
    else
      flash[:error] = "Unable to update product"
      redirect_back fallback_location: root_path, status: :bad_request
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
