# class ApplicationController < ActionController::Base

#   before_action :find_user

#   private

#   def find_user
#     if session[:user_id]
#       @login_merchant = Merchant.find_by(id: session[:user_id])
#     end
#   end
# end

class ApplicationController < ActionController::Base

  before_action :current_merchant

  private

  def current_merchant
    if session[:user_id]
      @login_merchant = Merchant.find_by(id: session[:user_id])
    end
  end

  def require_login
    if current_merchant.nil?
      flash[:warning] = "You must be logged in to view this section"
      redirect_to root_path
    end
  end
end
