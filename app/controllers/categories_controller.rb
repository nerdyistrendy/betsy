class CategoriesController < ApplicationController
  def new
    @category = Category.new
  end
  
  def create
    @category = Category.new(category_params)

    if @category.save
      flash[:success] = "Successfully created #{@category.name} ID# #{@category.id}"
      redirect_back(fallback_location: products_path)
      return
    else
      render :new, status: :bad_request
      return
    end
  end

  private

  def category_params
    return params.require(:category).permit(:name)
  end
end
