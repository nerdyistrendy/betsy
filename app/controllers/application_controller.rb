class ApplicationController < ActionController::Base

  before_action :start_session, :current_merchant

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

  def start_session
    session[:cart] ||= {}
  end
end
