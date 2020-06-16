class ReviewsController < ApplicationController

  def new
    @product = Product.find_by(id: params[:product_id])
    if !@product.nil?
      @review = Review.new
    else
      flash[:error] = "Invalid Product"
      redirect_to root_path
    end
  end

  def create
  end

  private

  def review_params
    return params.require(:review).permit(:reviewer, :text, :rating, :product_id)
  end
end
