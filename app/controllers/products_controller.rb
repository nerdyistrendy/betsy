class ProductsController < ApplicationController

  before_action :require_login, only: [:new, :create, :toggle_active, :edit, :update, :destroy]
  before_action :get_product, only: [:show, :edit, :update, :destroy, :toggle_active]
  before_action :get_product_for_cart, only: [:cart, :update_quant, :remove_from_cart]
  before_action :get_quantity, only: [:cart, :update_quant]
  before_action :get_merchant
  before_action :get_category, only: [:index]

  def index
    if params[:merchant_id]
      if @merchant
        @products = @merchant.active_products
      else
        flash[:warning] = "Invalid Merchant"
        redirect_to not_found_path
        return
      end
    elsif params[:category_id]
      if @category
        @products = @category.active_products.uniq
      else
        flash[:warning] = "Invalid Category"
        redirect_to not_found_path
        return
      end
    else
      @products = Product.active_products
    end
  end

  def show
    if @product.nil?
      flash[:warning] = "Invalid Product"
      redirect_to not_found_path
      return
    elsif !@product.active
      flash[:warning] = "Product not available"
      redirect_to not_found_path
      return
    else
    @reviews = @product.reviews
    @average_rating = @product.average_rating
    end
  end

  def new
    if @login_merchant.id == @merchant.id
      default_img = "https://lh3.googleusercontent.com/pw/ACtC-3fNC54ST39e4Tec1DUtd3utXYqTL_rBf6aMMWm_BsS86OvTd1vftlx-jjRiWT1NxoOknCLOeW4T91_I1a0NH6KJiayfEhfIP75xqeMmkuzeODi4B8jG2Uje3d5BBrhzhVtSZJQTWna_id37x96mteF6=w600-h400-no?authuser=0"

      @categories = Category.all.order("name DESC")
      @product = Product.new
      @product.img_url = default_img
    else
      flash[:warning] = "You are not authorized to complete this action"
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
        flash.now[:warning] = "Unable to add product"
        render :new, status: :bad_request
        return
      end
    else
      flash[:warning] = "You are not authorized to complete this action"
      redirect_back fallback_location: root_path
      return
    end
  end

  def edit
    @categories = Category.all.order("name DESC")
    
    if !@product
      flash[:warning] = "Invalid Product"
      redirect_back fallback_location: root_path
    elsif @product.merchant_id != @login_merchant.id
      flash[:warning] = "You are not authorized to edit that product."
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
          flash.now[:warning] = "Product could not be updated."
          render :edit, status: :bad_request
          return
        end
        return
      else
        flash[:warning] = "You are not authorized to edit that product."
      end
    else
      flash[:warning] = "Invalid Product"
    end
    redirect_to dashboard_path
    return
  end 

  def destroy
    if !@product
      flash[:warning] = "Invalid Product"
    else
      if @product.merchant.id == @login_merchant.id
        if @product.destroy
          flash[:success] = "Product successfully deleted."
        end 
        redirect_back fallback_location: root_path
        return
      else 
        flash[:warning] = "You are not authorized to complete this action"
      end 
    end
    redirect_back(fallback_location: root_path)
    return
  end

  def cart
    if @product.inventory > 0 && @quantity.to_i <= @product.inventory && @product.active
      @product.add_to_cart(session, @quantity)
      flash.now[:success] = "Product successfully added to your cart"
      render :show, status: :ok
      return
    else
      if @product.inventory == 0 
        flash.now[:warning] = "Sorry, this product is currently out of stock!"
        render :show, status: :bad_request
        return
      elsif @quantity >= @product.inventory
        flash.now[:warning] = "Quantity requested is larger that product inventory"
        render :show, status: :bad_request
        return
      elsif @product.active == false
        flash.now[:warning] = "This product is not for sale"
        render :show, status: :bad_request
        return
      end
    end
  end

  def update_quant
    if @product.inventory > 0 && @quantity.to_i <= @product.inventory
      @product.update_quant(session, @quantity)
      redirect_to order_cart_path
      return
    else
      if @product.inventory == 0
        flash[:warning] = "Sorry, this product is currently out of stock!"
        redirect_to order_cart_path #if someone bought the last of that product before you could check out.
        return
      elsif @quantity >= @product.inventory
        flash[:warning] = "Quantity requested is larger than product inventory"
        redirect_to order_cart_path
        return
      end
    end
  end

  def remove_from_cart
    @product.remove_from_cart(session)
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
        flash[:warning] = "You cannot retire another merchant's product"
      end
    else
      flash[:warning] = "Invalid Product"
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

  def get_product_for_cart
    return @product = Product.find_by(id: params[:product_id])
  end

  def get_quantity
    return @quantity = params[:quantity].to_i
  end

  def get_merchant
    return @merchant = Merchant.find_by(id: params[:merchant_id])
  end

  def get_category
    return @category = Category.find_by(id: params[:category_id])
  end
  
end
