class ApplicationController < ActionController::Base

  before_action :find_user

  private

  def find_user
    if session[:user_id]
      @login_merchant = Merchant.find_by(id: session[:user_id])
    end
  end
end
