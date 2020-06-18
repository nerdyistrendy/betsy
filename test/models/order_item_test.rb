require "test_helper"

describe OrderItem do
  describe "subtotal" do
    before do
      @orderitem = order_items(:foodie_smith_pickles)
      @knife = products(:knife)
    end

    it "will return the subtotal of purchase price of the order_item" do
      calculation = @knife.price * @orderitem.quantity
      expect(@orderitem.subtotal).must_be_instance_of Float
      expect(@orderitem.subtotal).must_equal calculation
    end
  end

  describe "self.filter_merchant_status" do
    it "returns the order items for a given merchant" do
      @weavery = merchants(:weavery)
      results = OrderItem.filter_merchant_status(merchant: @weavery)
      expect(results).must_equal @weavery.order_items
    end 

    it "returns the order items by status when passed in a string query" do
      @weavery = merchants(:weavery)
      results = OrderItem.filter_merchant_status(merchant: @weavery, status: "pending")
      results.each do |item|
        expect(item).must_be_instance_of OrderItem
        expect(item.merchant_id).must_equal @weavery.id
        expect(item.status).must_equal "pending"
      end
    end 
  end
end
