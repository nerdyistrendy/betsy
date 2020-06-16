require "test_helper"

describe OrderItemsController do
  before do
    @merchant_test = merchants(:houstonhatchhouse)
    @weavery = merchants(:weavery)
  end

  describe "Guest Users" do
    describe "index" do
      it "cannot access the order_items#index and will be redirected" do
        get merchant_order_items_path(@merchant_test)
        must_respond_with :redirect
        expect(flash[:warning]).must_equal "You must be logged in to view this section"
      end

      it "cannot access the order_items#index with string query and will be redirected" do
        get merchant_order_items_path(@merchant_test, :status => "pending")
        must_respond_with :redirect
        expect(flash[:warning]).must_equal "You must be logged in to view this section"
      end

      it "redirects for an invalid search" do
        @invalid_order_item_id = -5
        get merchant_order_items_path(@invalid_order_item_id)
        must_respond_with :redirect
        expect(flash[:warning]).must_equal "You must be logged in to view this section"
      end
    end
  end

  describe "Logged in Merchants" do
    before do
      perform_login(@merchant_test)
    end

    describe "index" do
      it "returns the index of order items for a given merchant" do
        get merchant_order_items_path(@merchant_test.id)
        must_respond_with :success
      end 

      it "returns the index of order items by status when passed in a string query" do
        get merchant_order_items_path(@merchant_test, :status => "pending")
        must_respond_with :success

        get merchant_order_items_path(@merchant_test, :status => "shipped")
        must_respond_with :success
      end 

      it "redirects if the fulfillment page does not belong to the logged in merchant" do        
        get merchant_order_items_path(@weavery)
        must_respond_with :redirect
        expect(flash[:warning]).must_equal "You are not authorized to view this section"
      end
      
      it "redirects for an invalid search" do
        @invalid_order_item_id = -5
        get merchant_order_items_path(@invalid_order_item_id)
        must_respond_with :redirect
        expect(flash[:warning]).must_equal "You are not authorized to view this section"
      end
    end
  end
end
