class CategoriesController < ApplicationController
  before_action :require_login, only: [:new, :create]

  def new
    @category = Category.new
  end
  
  def create
    @category = Category.new(category_params)

    if @category.save
      flash[:success] = "Successfully created Category ID# #{@category.id} #{@category.name} "
      redirect_back(fallback_location: root_path)
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
