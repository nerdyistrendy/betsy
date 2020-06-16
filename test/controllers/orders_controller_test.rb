require "test_helper"

describe OrdersController do
  describe "Guest Users" do
    describe 'cart' do
    end

    describe "show" do
      it "cannot access the order_path and will be redirected" do
        get order_path(orders(:pickle_order))
        must_respond_with :redirect
        expect(flash[:warning]).must_equal "You must be logged in to view this section"
      end
    end
  end

  describe "Logged-in Merchants" do
    before do
      @order = orders(:pickle_order)
      @included_item = order_items(:foodie_smith_knife)
      @blacksmith = merchants(:blacksmith)
      perform_login(@blacksmith)
    end

    describe 'cart' do
    end

    describe "show" do
      it "can access the order_path if the order includes order_items from the logged in merchant" do
        @order.order_items << @included_item
        @order.save!
        get order_path(@order)
        must_respond_with :success
      end

      it "cannot access an order_path if the order does NOT include order_items from the logged in merchant" do
        order_excluded = orders(:knife_order)
        get order_path(order_excluded)
        must_respond_with :redirect
        expect(flash[:warning]).must_equal "You are not authorized to view this section"
      end

      it "will be redirected if the order does not exist" do
        get order_path(-1)
        must_respond_with :redirect
        expect(flash[:warning]).must_equal "Invalid Order"
      end
    end
  end
end
