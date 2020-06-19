require "test_helper"

describe ReviewsController do
  before do
    @blacksmith_test = merchants(:blacksmith)
    @pickles_test = products(:pickles)
    @tent_test = products(:tent)
    @excitable_review_test = reviews(:excitable_pickle_review)

    @review_hash = {
      review: {
        text: "Man, I love these pickles!",
        rating: 5,
        reviewer: "Excitable Foodie"
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
      it "will redirect to product page when created" do
        post product_reviews_path(@pickles_test.id), params: @review_hash
      
        must_respond_with :redirect
        must_redirect_to product_path(@pickles_test.id)
      end

      it "can create a review by an unauthenticated user" do
        expect {
          post product_reviews_path(@pickles_test.id), params: @review_hash
        }.must_differ 'Review.count', 1
  
        expect(Review.last.reviewer).must_equal @review_hash[:review][:reviewer]
        expect(Review.last.text).must_equal @review_hash[:review][:text]
        expect(Review.last.rating).must_equal @review_hash[:review][:rating]

        expect(Review.last.product).wont_be_nil
        expect(Review.last.product.name).must_equal @pickles_test.name
      end

      it "will respond with bad request and send error message if review failed to save" do
        @review_hash[:review][:rating] = nil
        
        post product_reviews_path(@pickles_test.id), params: @review_hash
        
        must_respond_with :bad_request
        expect(flash.now[:warning]).must_equal "Unable to add review"
      end

      it "will redirect and send error message if product is invalid" do
        post product_reviews_path(-1), params: @review_hash
        
        must_respond_with :redirect
        expect(flash[:warning]).must_equal "Invalid Product"
      end
    end
  end

  describe "Logged In Merchant" do
    before do
      perform_login(@blacksmith_test)
    end

    describe "new" do
      it "can get review form for other merchants products" do
        get new_product_review_path(@tent_test.id)

        must_respond_with :success
      end

      it "will redirect to product page for a merchant's own product" do
        get new_product_review_path(@pickles_test.id)

        must_respond_with :redirect
        must_redirect_to product_path(@pickles_test.id)
      end
    end

    describe "create" do
      it "can create a review by a merchant for another merchant's products" do
        expect {
          post product_reviews_path(@tent_test.id), params: @review_hash
        }.must_differ 'Review.count', 1
  
        must_respond_with :redirect
        must_redirect_to product_path(@tent_test.id)

        expect(Review.last.reviewer).must_equal @review_hash[:review][:reviewer]
        expect(Review.last.text).must_equal @review_hash[:review][:text]
        expect(Review.last.rating).must_equal @review_hash[:review][:rating]

        expect(Review.last.product).wont_be_nil
        expect(Review.last.product.name).must_equal @tent_test.name
      end

      it "will redirect to product page for a merchant's own product" do
        post product_reviews_path(@pickles_test.id), params: @review_hash

        must_respond_with :redirect
        must_redirect_to product_path(@pickles_test.id)
      end
    end
  end
end
