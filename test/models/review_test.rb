require "test_helper"

describe Review do
  before do
    @excitable_review_test = reviews(:excitable_pickle_review)
    @pickle_test = products(:pickles)
    @blacksmith_test = merchants(:blacksmith)
    @confused_review_test = reviews(:confused_pickle_review)
  end

  describe "validations" do
    it "is valid when all fields are present" do
      expect(@excitable_review_test.valid?).must_equal true
    end

    it "is invalid when missing or invalid text" do
      invalid_excitable_review = @excitable_review_test
      invalid_excitable_review.text = nil  

      invalid_confused_review = @confused_review_test
      invalid_confused_review.text = ""

      expect(invalid_excitable_review.valid?).must_equal false
      expect(invalid_confused_review.valid?).must_equal false
    end

    it "is invalid when missing or invalid rating" do
      invalid_excitable_review = @excitable_review_test
      invalid_excitable_review.rating = nil  

      invalid_confused_review = @confused_review_test
      invalid_confused_review.rating = "5"

      expect(invalid_excitable_review.valid?).must_equal false
      expect(invalid_confused_review.valid?).must_equal false
    end

    it "is invalid when missing or invalid reviewer" do
      invalid_excitable_review = @excitable_review_test
      invalid_excitable_review.reviewer = nil  

      invalid_confused_review = @confused_review_test
      invalid_confused_review.reviewer = ""

      expect(invalid_excitable_review.valid?).must_equal false
      expect(invalid_confused_review.valid?).must_equal false
    end
  end

  describe "relations" do
    describe "products" do
      it "can have a single product" do
        expect(@excitable_review_test.valid?).must_equal true
      end

      it "is invalid when it doesn't belong to a product" do
        invalid_excitable_review = @excitable_review_test
        invalid_excitable_review.product = nil

        expect(@excitable_review_test.valid?).must_equal false
      end
    end
  end
end
