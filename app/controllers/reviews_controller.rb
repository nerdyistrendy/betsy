class ReviewsController < ApplicationController
  before_action :get_product

  def new
    if !@product.nil?
      @review = Review.new
    else
      flash[:error] = "Invalid Product"
      redirect_to root_path
    end
  end

  def create
    if @login_merchant
    else
      @review = Review.new(review_params)
      @review.product_id = @product.id

      if @review.save
        flash[:success] = "Successfully added review"
        redirect_to product_path(@product.id)
        return
      else
        flash.now[:error] = "Unable to add review"
        render :new, status: :bad_request
        return
      end
    end
  end

  private

  def review_params
    return params.require(:review).permit(:reviewer, :text, :rating, :product_id)
  end

  def get_product
    return @product = Product.find_by(id: params[:product_id])
  end
end
