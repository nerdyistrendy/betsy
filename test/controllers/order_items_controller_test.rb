require "test_helper"

describe OrderItemsController do
  before do
    @merchant_test = merchants(:houstonhatchhouse)
    @weavery = merchants(:weavery)
    @orderitem = order_items(:foodie_smith_pickles)
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

    describe "ship" do
      it "cannot access the order_items#ship and will be redirected" do
        patch ship_item_path(@orderitem)
        must_respond_with :redirect
        expect(flash[:warning]).must_equal "You must be logged in to view this section"
      end
    end

    describe "cancel" do
      it "cannot access the order_items#ship and will be redirected" do
        delete cancel_item_path(@orderitem)
        must_respond_with :redirect
        expect(flash[:warning]).must_equal "You must be logged in to view this section"
      end
    end

  end

  describe "Logged in Merchants" do
    describe "index" do
      before do
        perform_login(@merchant_test)
      end

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

    describe "ship" do
      before do
        perform_login(@weavery)
      end

      it "can successfully ship a pending order_item" do
        @orderitem.update!(status: "pending")
        patch ship_item_path(@orderitem)
        must_respond_with :redirect
        expect(flash[:success]).must_equal "Successfully Shipped"
      end

      it "can successfully ship a pending order_item" do
        single_item = order_items(:stabby_smith_knife)
        single_item.update!(status: "pending")

        patch ship_item_path(single_item)
        must_respond_with :redirect
        expect(flash[:success]).must_equal "Successfully Shipped"
        order = Order.find_by(id: single_item.order_id)
        expect(order.status).must_equal "complete"
      end

      it "is unable to ship a shipped item" do
        shipped_item = order_items(:stabby_smith_knife)
        patch ship_item_path(shipped_item)
        must_respond_with :redirect
        expect(flash[:warning]).must_equal "This order item was previously shipped"
      end

      it "is unable to ship a cancelled item" do
        @orderitem.update!(status: "cancelled")
        patch ship_item_path(@orderitem)
        must_respond_with :redirect
        expect(flash[:warning]).must_equal "Unable to ship a cancelled item"
      end

      it "is unable to ship another merchant's product" do
        other_merchant_order = order_items(:pickle_lover_pickles)
        other_merchant_order.update!(status: "pending")
        patch ship_item_path(other_merchant_order)
        must_respond_with :redirect
        expect(flash[:warning]).must_equal "Invalid Order Item"
      end
    end

    describe "cancel" do
      before do
        perform_login(@weavery)
      end

      it "can successfully cancel a pending order_item" do
        @orderitem.update!(status: "pending")
        delete cancel_item_path(@orderitem)
        must_respond_with :redirect
        expect(flash[:success]).must_equal "Successfully Cancelled"
      end

      it "is unable to cancel a shipped item" do
        shipped_item = order_items(:stabby_smith_knife)
        delete cancel_item_path(shipped_item)
        must_respond_with :redirect
        expect(flash[:warning]).must_equal "Unable to cancel a shipped item"
      end

      it "is unable to cancel a cancelled item" do
        @orderitem.update!(status: "cancelled")
        delete cancel_item_path(@orderitem)
        must_respond_with :redirect
        expect(flash[:warning]).must_equal "This order item was previously cancelled"
      end

      it "is unable to ship another merchant's product" do
        other_merchant_order = order_items(:pickle_lover_pickles)
        other_merchant_order.update!(status: "pending")
        delete cancel_item_path(other_merchant_order)
        must_respond_with :redirect
        expect(flash[:warning]).must_equal "Invalid Order Item"
      end
    end
  end
end
