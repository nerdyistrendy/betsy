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

    it "is invalid when missing a req'd field is missing" do
      invalid_pickles = @pickle_test
      invalid_pickles.name = nil  

      invalid_tent = @tent_test
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
end
