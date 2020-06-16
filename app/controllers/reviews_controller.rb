class ReviewsController < ApplicationController

  def new
    @product = params[:product_id]
    @review = Review.new
  end

  def create
  end

  private

  def review_params
    return params.require(:review).permit(:reviewer, :text, :rating, :product_id)
  end
end
