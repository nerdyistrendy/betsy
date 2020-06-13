require "test_helper"

describe Merchant do
  before do
    @blacksmith_test = merchants(:blacksmith)
    @pickle_test = products(:pickles)
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
end
