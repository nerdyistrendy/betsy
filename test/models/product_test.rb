require "test_helper"

describe Product do
  before do
    @pickle_test = products(:pickles)
    @food_test = categories(:food)
    @blacksmith_test = merchants(:blacksmith)
  end

  describe "validations" do
    it "is valid when all fields are present" do
      expect(@pickle_test.valid?).must_equal true
    end

    it "is invalid when missing a req'd field is missing" do
      invalid_pickles = @pickle_test
      invalid_pickles.name = nil  

      invalid_tent = products(:tent)
      invalid_tent.inventory = "a string!"

      expect(invalid_pickles.valid?).must_equal false
      expect(invalid_tent.valid?).must_equal false
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
        @pickle_test.categories << @food_test

        expect(@pickle_test.categories).wont_be_empty
        expect(@pickle_test.categories.first.products.name).must_match @food_test.products.name
      end
    end
  end
end
