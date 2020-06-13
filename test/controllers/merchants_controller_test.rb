require "test_helper"




























describe MerchantsController do
  describe "show" do 
    it "successfully renders the show page for a merchant's dashboard" do

      get "/merchants/2"

      must_respond_with :success
    end

    it "successfully returns a 404 error for merchants not present in the database" do

      get "/merchants/necrotoes"

      must_respond_with :not_found
    end 
  end
end
