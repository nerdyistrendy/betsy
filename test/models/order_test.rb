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
end
