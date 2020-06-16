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
end
