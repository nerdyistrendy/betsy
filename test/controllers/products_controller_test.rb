require "test_helper"

describe ProductsController do
  before do
    @product = YML 
  end
  
  describe "show" do
    it "can show a valid product" do
      get product_path(@product.id)
      must_respond_with :success
    end

    it "will redirect to index if invalid id is given" do
      get product_path(-5)

      must_redirect_to root_path
    end
    before do
      @book = Book.first
    end

    it "will get show for valid ids" do
      # Arrange
      valid_book_id = @book.id
  
      # Act
      get "/books/#{valid_book_id}"
  
      # Assert
      must_respond_with :success
    end
  
    it "will respond with not_found for invalid ids" do
      # Arrange
      invalid_book_id = 999
  
      # Act
      get "/books/#{invalid_book_id}"
  
      # Assert
      must_respond_with :not_found
    end
  end
  
  describe "new" do

  end

  describe "create" do
    it "will create a new product with the appropriate params" do
      expect{
        post merchant_(@passenger.id), params: nil
      }.must_change "Trip.count", 1

      new_trip = Trip.find_by(id: @passenger.trips.last.id)

      expect(new_trip.driver.available).must_equal false

      must_respond_with :redirect
      must_redirect_to passenger_path(@passenger.id)
    end
  end
end