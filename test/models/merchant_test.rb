require "test_helper"

describe Merchant do
  before do
    @blacksmith_test = merchants(:blacksmith)
    @pickle_test = products(:pickles)
    @weavery = merchants(:weavery)
    @hopeful = merchants(:hopeful)
  end
  
  describe "active_products" do
    it "will retrieve all products where active is true" do
      products_arr = @blacksmith_test.active_products

      expect(products_arr).must_include @pickle_test
      products_arr.each do |p|
        expect(p.active).must_equal true
      end
    end

    it "will ignore inactive products" do
      inactive_pickle_test = products(:inactive_pickles)
      products_arr = @blacksmith_test.active_products

      expect(products_arr).wont_include inactive_pickle_test
    end
  end

  describe "total_revenue" do

    it "will return total revenue if not passed in a status filter" do
      peaceful = merchants(:peaceful)
      @pickle_test.update!(merchant_id: peaceful.id)
      quant = 10
      new_order = OrderItem.create!(merchant_id: peaceful.id, quantity: quant, product_id: @pickle_test.id, order_id: Order.last.id, status: "pending")
      expect(peaceful.total_revenue).must_equal (@pickle_test.price * quant)
      
      expect(@weavery.total_revenue).must_equal 245.0
    end

    it "will return revenue by status when passed in a status filter" do
      shipped_item = order_items(:stabby_smith_knife) # @weavery's only shipped order_item
      shipped_product = Product.find_by(id: shipped_item.product_id)
      expect(@weavery.total_revenue("shipped")).must_equal (shipped_product.price * shipped_item.quantity)

      expect(@weavery.total_revenue("unshipped")).must_equal 195.0
    end

    it "will return a message if there is no revenue made yet" do
      expect(@hopeful.total_revenue).must_equal "No money made yet!"
    end

  end
end
