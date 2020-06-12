class MerchantsController < ApplicationController
  def create
    redirect_to products_path
    # auth_hash = request.env["omniauth.auth"]
    # user = Merchant.find_by(uid: auth_hash[:uid], provider: auth_hash[:provider])
    # if user         # User was found in the database
    #   flash[:status] = :success
    #   flash[:result_text] = "Successfully logged in as existing user #{user.username}"
    # else
    #   # User doesn't match anything in the DB
    #   user = Merchant.build_from_github(auth_hash)

    #   if user.save
    #     flash[:status] = :success
    #     flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
    #   else
    #     flash[:status] = :failure
    #     flash[:result_text] = "Could not log in"
    #     flash[:messages] = user.errors.messages
    #     redirect_to root_path
    #   end
    # end
    
    # # If we get here, we have a valid user instance
    # session[:user_id] = user.id
    # redirect_to root_path
  end
end
