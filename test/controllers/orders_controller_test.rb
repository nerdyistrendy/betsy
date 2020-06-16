require "test_helper"

describe OrdersController do

  describe 'new' do
    it "responds with success" do
      get(new_order_path)
      must_respond_with :success
    end
  end
  
  describe 'cart' do
    it "responds with success" do
      get(order_cart_path)
      must_respond_with :success
    end
  end

  describe 'create' do
    before do
      @product = products(:pickles)
      @quantity = 2 
      patch product_cart_path(@product.id), params:{"quantity": @quantity}
      @order = { 
        order: { 
          name: 'Pickle Lover',
          email: 'pickles4lyf@e.mail',
          mailing_address: '1234 Pickles Blvd',
          cc_name: 'Joe Smith',
          cc_cvv: 123,
          cc_number: 1234123412341234,
          cc_exp: Date.new(2022, 3, 1).to_s,
          zipcode: 98765
        }
      }
    end

    it 'can create a valid order and associated order_items' do
      expect{post(orders_path params: @order)}.must_differ 'Order.count && OrderItem.count', 1
      order = Order.last
  
      expect(order).must_be_instance_of Order
      expect(order.valid?).must_equal true
      expect(order.order_items.count).must_equal 1

      expect(order.order_items.first).must_be_instance_of OrderItem
      expect(order.order_items.first.valid?).must_equal true
      expect(order.order_items.count).must_equal 1
      expect(order.order_items.first.product).must_equal @product
    end

    it 'can change order status to paid' do
      post(orders_path params: @order)
      order = Order.last

      expect(order.status).must_equal 'paid'
    end

    it 'can set order_item status to pending' do
      post(orders_path params: @order)
      order = Order.last

      expect(order.order_items.first.status).must_equal 'pending'
    end

    it 'can decrease product in order\'s inventory' do
      expect{post(orders_path params: @order)}.must_differ '@product.reload.inventory', -@quantity
    end

    it 'can clear the cart' do
      expect(session[:cart].count).must_equal 1
      expect(session[:cart]["#{@product.id}"]).must_equal @quantity

      post(orders_path params: @order)

      expect(session[:cart].empty?).must_equal true
      expect(session[:cart]["#{@product.id}"]).must_be_nil
    end

    it 'can redirect to confirmation page if order creation is successful' do
      post(orders_path params: @order)
      must_respond_with :redirect
    end

    it 'does not create an order or order_items if order params are invalid' do
      expect{post(orders_path params: {order: {name: nil}})}.wont_differ 'Order.count && OrderItem.count'
      must_respond_with :bad_request
    end
  end

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

  describe 'confirmation' do
    before do
      @product = products(:pickles)
      @quantity = 2 
      patch product_cart_path(@product.id), params:{"quantity": @quantity}
      @order = { 
        order: { 
          name: 'Pickle Lover',
          email: 'pickles4lyf@e.mail',
          mailing_address: '1234 Pickles Blvd',
          cc_name: 'Joe Smith',
          cc_cvv: 123,
          cc_number: 1234123412341234,
          cc_exp: Date.new(2022, 3, 1).to_s,
          zipcode: 98765
        }
      }
      post(orders_path params: @order)
      @found_order = Order.last
    end
    
    it 'can get a confirmation page' do
      get order_confirmation_path(@found_order.id)
      must_respond_with :ok
    end

    it 'responds with bad request of page not found' do
      get order_confirmation_path(1232133)
      must_respond_with :bad_request
    end
  end
end
