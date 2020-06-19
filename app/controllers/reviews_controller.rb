class ReviewsController < ApplicationController
  before_action :get_product

  def new
    if @product
      if @login_merchant && (@product.merchant_id == @login_merchant.id)
        flash[:warning] = "You can't review your own product"
        redirect_to product_path(@product.id)
        return
      else
        @review = Review.new
        @review.rating = 5
      end
    else
      flash[:warning] = "Invalid Product"
      redirect_to root_path
    end
    return
  end

  def create
    if @product
      @review = Review.new(review_params)
      @review.product_id = @product.id

      if @login_merchant && (@product.merchant_id == @login_merchant.id)
        flash[:warning] = "You cannot review your own product"
      elsif @review.save
        flash[:success] = "Successfully added review"
      else
        flash.now[:warning] = "Unable to add review"
        render :new, status: :bad_request
        return
      end
      redirect_to product_path(@product.id)
    else
      flash[:warning] = "Invalid Product"
      redirect_to root_path
    end
    return
  end

  private

  def review_params
    return params.require(:review).permit(:reviewer, :text, :rating, :product_id)
  end

  def get_product
    return @product = Product.find_by(id: params[:product_id])
  end
end
