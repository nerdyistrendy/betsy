require "test_helper"

describe Category do
  before do
    @food_test = categories(:food)
    @pickle_test = products(:pickles)
  end
  
  describe "active_products" do
    it "will retrieve all products where active is true" do
      products_arr = @food_test.active_products

      expect(products_arr).must_include @pickle_test
      products_arr.each do |p|
        expect(p.active).must_equal true
      end
    end

    it "will ignore inactive products" do
      inactive_pickle = products(:inactive_pickles)
      products_arr = @food_test.active_products

      expect(products_arr).wont_include inactive_pickle
    end
  end
end
