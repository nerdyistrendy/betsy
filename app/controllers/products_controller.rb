class ProductsController < ApplicationController

  before_action :require_login, only: [:new, :create, :toggle_active, :edit, :update, :destroy]
  before_action :get_product, except: [:index, :new, :create, :cart]
  before_action :get_merchant
  before_action :get_category, only: [:index]

  def index
    if params[:merchant_id]
      if @merchant
        @products = @merchant.active_products
      else
        flash[:error] = "Invalid Merchant"
        redirect_to dashboard_path
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
      redirect_to not_found_path, status: :not_found
      return
    elsif !@product.active
      flash[:error] = "Product not available"
      redirect_to products_path, status: :not_found
      return
    else
    @reviews = @product.reviews
    @average_rating = @product.average_rating
    end
  end

  def new
    if @login_merchant.id == @merchant.id
      default_img = "https://lh3.googleusercontent.com/pw/ACtC-3eMhEM2kaTc-RlRyVudYKP08KOdRO6QbvXTc_PkmzKzXTIkCqRDIa06GMT1FaJr-lDgIcjmnR5hEEFOCYf4YUDKfozbnOhaOw02IpXMOTr2LW4L2S2PXJfedaWYHq6uTewLUuufgMD0VBs_xdtE7FUy=w1350-h900-no?authuser=0"

      @categories = Category.all.order("name DESC")
      @product = Product.new
      @product.img_url = default_img
      @product.price = 0.00
      @product.inventory = 0
    else
      flash[:error] = "You are not authorized to complete this action"
      redirect_back fallback_location: root_path
    end
  end

  def create
    if @merchant.id == @login_merchant.id
      @product = Product.new(product_params)
      @product.active = true
      @product.merchant = @login_merchant

      if @product.save
        flash[:success] = "Successfully added product: #{@product.name}"
        redirect_to dashboard_path
        return
      else
        flash.now[:error] = "Unable to add product"
        render :new, status: :bad_request
        return
      end
    else
      flash[:error] = "You are not authorized to complete this action"
      redirect_back fallback_location: root_path
      return
    end
  end

  def edit
    @categories = Category.all.order("name DESC")
    
    if !@product
      flash[:error] = "Invalid Product"
      redirect_back fallback_location: root_path
    elsif @product.merchant_id != @login_merchant.id
      flash[:error] = "You are not authorized to edit that product."
      redirect_to product_path(@product.id)
    end
    return
  end 

  def update
    if @product
      if @product.merchant_id == @login_merchant.id
        if @product.update(product_params)
          flash[:success] = "Product successfully updated."
          redirect_to dashboard_path
        else
          flash.now[:error] = "Product could not be updated."
          render :edit, status: :bad_request
          return
        end
        return
      else
        flash[:error] = "You are not authorized to edit that product."
      end
    else
      flash[:error] = "Invalid Product"
    end
    redirect_to dashboard_path
    return
  end 

  def destroy
    @product = Product.find_by(id: params[:id])

    if !@product
      flash[:error] = "Invalid Product"
    else
      if @product.merchant.id == @login_merchant.id
        if @product.destroy
          flash[:success] = "Product successfully deleted."
        else
          flash[:error] = "Product could not be deleted."
        end 
        redirect_back fallback_location: root_path
        return
      else 
        flash[:error] = "You are not authorized to complete this action"
      end 
    end
    redirect_back(fallback_location: root_path)
    return
  end

  def cart
    @product = Product.find_by(id: params[:product_id])
    @quantity = params[:quantity].to_i

    if @product.inventory > 0 && @quantity.to_i <= @product.inventory
      session[:cart]["#{@product.id}"] = @quantity
      flash.now[:success] = "Product successfully added to your cart"
      render :show, status: :ok
      return
    else
      if @product.inventory == 0
        flash.now[:error] = "Sorry, this product is currently out of stock!"
        render :show, status: :bad_request
        return
      elsif @quantity >= @product.inventory
        flash.now[:error] = "Quantity requested is larger that product inventory"
        render :show, status: :bad_request
        return
      end
    end
  end

  def update_quant
    @product = Product.find_by(id: params[:product_id])
    @quantity = params[:quantity].to_i
    if @product.inventory > 0 && @quantity.to_i <= @product.inventory
      session[:cart]["#{@product.id}"] = @quantity
      redirect_to order_cart_path
      return
    else
      if @product.inventory == 0
        flash.now[:error] = "Sorry, this product is currently out of stock!"
        redirect_to order_cart_path #if someone bought the last of that product before you could check out.
        return
      elsif @quantity >= @product.inventory
        flash.now[:error] = "Quantity requested is larger than product inventory"
        redirect_to order_cart_path
        return
      end
    end
  end

  def remove_from_cart
    session[:cart].delete(params[:product_id])
    flash.now[:success] = "Product successfully removed from your cart"
    redirect_to order_cart_path
    return
  end

  def toggle_active
    if @product
      current_state = @product.active
      if @login_merchant.id == @product.merchant_id
        @product.update!(active: !current_state)
        flash[:success] = "Product was successfully updated"
        redirect_back fallback_location: root_path
        return
      else
        flash[:error] = "You cannot retire another merchant's product"
      end
    else
      flash[:error] = "Invalid Product"
    end
    redirect_to root_path
    return
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
