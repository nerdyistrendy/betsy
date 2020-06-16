require "test_helper"

describe ReviewsController do
  before do
    @blacksmith_test = merchants(:blacksmith)
    @pickles_test = products(:pickles)
    @excitable_review_test = reviews(:excitable_pickle_review)

    @review_hash = {
      review: {
        text: "Man, I love these pickles!",
        rating: 5,
        reviewer: "Excitable Foodie",
        product: @pickles_test
      }
    }
  end
  
  describe "Guest User" do
    describe "new" do
      it "can get the nested path" do
        get new_product_review_path(@pickles_test.id)

        must_respond_with :success
      end

      it "will redirect to products for an invalid product" do
        get new_product_review_path(-5)

        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "create" do
    end
  end

  describe "Logged In Merchant" do
    describe "new" do
      it "can get the nested path" do
        get products_path

        must_respond_with :success
      end
    end

    describe "create" do
    end
  end
end
