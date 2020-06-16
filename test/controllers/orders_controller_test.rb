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
      @order[:order][:zipcode] = nil
      expect{post(orders_path params: @order)}.wont_differ 'Order.count && OrderItem.count'
      must_respond_with :bad_request
    end

  end

  describe 'confirmation' do

  end


end
