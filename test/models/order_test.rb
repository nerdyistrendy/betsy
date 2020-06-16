require "test_helper"

describe Order do
  describe "#order_include_merchant" do
    before do
      @blacksmith = merchants(:blacksmith)
    end

    it "returns false if the order does not include items from the merchant" do
      order_excluded = orders(:knife_order)         #does not include products from @blacksmith
      expect(order_excluded.order_include_merchant(@blacksmith)).must_equal false
    end

    it "returns a truthy result of the collection of order items from the merchant" do
      order_included = orders(:knife_pickle_order)  #pickle is from @blacksmith
      result = order_included.order_include_merchant(@blacksmith)

      expect(result).wont_be_nil
      result.each do |item|
        expect(item).must_be_instance_of OrderItem
        expect(item.merchant_id).must_equal @blacksmith.id
      end
    end
  end


  describe "mark_order_complete" do
    before do
      @single_order = orders(:pickle_order)
      @single_item = @single_order.order_items.first
    end

    it "will mark an order complete if the order items are shipped" do
      expect(@single_order.status).must_equal "pending"

      @single_item.update!(status: "shipped")
      @single_order.mark_order_complete
      expect(@single_order.status).must_equal "complete"
    end

    it "will mark an order complete if all order items are either shipped or cancelled" do
      tent_pickle = orders(:knife_pickle_order)
      item1 = tent_pickle.order_items.first
      item2 = tent_pickle.order_items.last
      expect(tent_pickle.status).wont_equal "complete"

      item1.update!(status: "cancelled")
      item2.update!(status: "shipped")
      tent_pickle.mark_order_complete
      expect(tent_pickle.status).must_equal "complete"
    end

    it "will not change order status if there are still pending order items" do
      expect{@single_order.mark_order_complete}.wont_change "@single_order.status"
    end
  end
end
