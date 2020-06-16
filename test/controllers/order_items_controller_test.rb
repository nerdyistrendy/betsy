require "test_helper"

describe OrderItemsController do

  before do
    @merchant_test = merchants(:houstonhatchhouse)
    @invalid_order_item_id = -5
  end

  describe "index" do
    it "returns the index of order items for a given merchant" do
      perform_login(@merchant_test)
      get merchant_order_items_path(@merchant_test.id)

      must_respond_with :success
    end 

    it "returns a 404 for an invalid search" do
    get "/merchants/#{@invalid_order_item_id}"
    
    must_respond_with :not_found
    end
  end
end
