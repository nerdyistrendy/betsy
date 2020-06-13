require "test_helper"

describe Product do
  before do
    @pickle_test = products(:pickles)
    @blacksmith_test = merchants(:blacksmith)
    @tent_test = products(:tent)
  end

  describe "validations" do
    it "is valid when all fields are present" do
      expect(@pickle_test.valid?).must_equal true
    end

    it "is invalid when invalid or missing name" do
      invalid_pickles = @pickle_test
      invalid_pickles.name = nil  

      invalid_tent = @tent_test
      invalid_tent.name = ""

      expect(invalid_pickles.valid?).must_equal false
      expect(invalid_tent.valid?).must_equal false
    end

    it "is invalid when missing description" do
      invalid_pickles = @pickle_test
      invalid_pickles.description = nil  

      expect(invalid_pickles.valid?).must_equal false
    end

    it "is invalid when missing img_url" do
      invalid_pickles = @pickle_test
      invalid_pickles.img_url = nil  

      expect(invalid_pickles.valid?).must_equal false
    end

    it "is invalid when invalid or missing inventory" do
      invalid_pickles = @pickle_test
      invalid_pickles.inventory = nil  

      invalid_tent = @tent_test
      invalid_tent.inventory = "five"

      expect(invalid_pickles.valid?).must_equal false
      expect(invalid_tent.valid?).must_equal false
    end

    it "is invalid when invalid or missing price" do
      invalid_pickles = @pickle_test
      invalid_pickles.price = nil  

      invalid_tent = @tent_test
      invalid_tent.price = "$5.00"

      expect(invalid_pickles.valid?).must_equal false
      expect(invalid_tent.valid?).must_equal false
    end

    it "is valid with or without categories" do
      expect(@pickle_test.valid?).must_equal true
      expect(@tent_test.valid?).must_equal true
    end
  end

  describe "relations" do
    describe "merchants" do
      it "can have a merchant" do 
        expect(@pickle_test).must_respond_to :merchant
        expect(@pickle_test.merchant.username).must_equal @blacksmith_test.username
      end

      it "is invalid when it doesn't belong to a merchant" do
        invalid_pickle = @pickle_test
        invalid_pickle.merchant = nil
        
        expect(invalid_pickle.valid?).must_equal false
      end
    end

    describe "categories" do
      it "can have categories" do
        @pickle_test.categories << categories(:lifestyle)

        expect(@pickle_test.categories).wont_be_empty
        expect(@pickle_test.categories).must_include categories(:lifestyle)
      end

    #   it "will not add a duplicate category" do
        
    #     @tent_test.categories << categories(:food)
    #     before_count = @tent_test.categories.count
    #     expect(before_count).must_equal 1

    #     @tent_test.categories << categories(:food)

    #     expect(@tent_test.categories.count).must_equal before_count
    #   end
    end
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
