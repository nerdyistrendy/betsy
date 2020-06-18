class MerchantsController < ApplicationController
  before_action :require_login, only: [:logout, :dashboard]

  def dashboard
    @merchant = @login_merchant
    @orders = @login_merchant.orders
    @products = @login_merchant.products
  end 
  
  def create
    auth_hash = request.env["omniauth.auth"]
    merchant = Merchant.find_by(email: auth_hash["info"]["email"])
    if merchant         # Merchant was found in the database
      flash[:success] = "Successfully logged in as existing user #{merchant.username}"
    else
      # Merchant doesn't match anything in the DB
      merchant = Merchant.build_from_github(auth_hash)

      if merchant.save
        flash[:success] = "Successfully created new user #{merchant.username} with ID #{merchant.id}"
      else
        flash[:failure] = merchant.errors.messages
        redirect_to merchants_path
      end
    end
    
    # If we get here, we have a valid user instance
    session[:user_id] = merchant.id
    redirect_to root_path
  end

  def logout
    session[:user_id] = nil
    flash[:success] = "Successfully logged out"
    redirect_to root_path
  end
end
