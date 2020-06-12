require "test_helper"

describe ProductsController do
  before do
    @product = products(:pickles)
    @product.save
    @merchant = merchants(:blacksmith)
    @merchant.save
    # @merchant = Merchant.create(username: "anacortesblacksmith", email: "cloud@abco.com")
    @product_hash = {
      product: {
        name: "Crisp Pickles",
        description: "One jar of homegrown pickles.",
        img_url: "yourmom.com/image.jpeg",
        inventory: 40,
        price: 2
      }
    }
  end

  describe "show" do
    it "will get show for valid ids" do
      valid_product_id = @product.id
  
      get "/products/#{valid_product_id}"
  
      must_respond_with :success
    end
  
    it "will respond with not_found for invalid ids" do
      invalid_product_id = -5
  
      get "/products/#{invalid_product_id}"
  
      must_respond_with :not_found
    end
  end
  
  describe "new" do
    it "can get the new_merchant_product_path" do
      get new_merchant_product_path(@merchant.id)

      must_respond_with :success
    end

    # it "will redirect to the root if merchant isn't logged in" do
    #  TODO

    # end
  end

  describe "create" do
    it "can create a product" do
      expect {
        post merchant_products_path(@merchant.id), params: @product_hash
      }.must_differ 'Product.count', 1
  
      must_respond_with  :redirect
      must_redirect_to product_path(Product.last.id)
      expect(Product.last.name).must_equal @product_hash[:product][:name]
      expect(Product.last.description).must_equal @product_hash[:product][:description]
      expect(Product.last.img_url).must_equal @product_hash[:product][:img_url]
      expect(Product.last.active).must_equal true
      expect(Product.last.inventory).must_equal @product_hash[:product][:inventory]
      expect(Product.last.price).must_equal @product_hash[:product][:price]
      expect(Product.last.merchant).wont_be_nil
      expect(Product.last.merchant.username).must_equal @merchant.username
    end

    it "will not create a product with invalid params" do
      @product_hash[:product][:name] = nil

      expect {
        post merchant_products_path(@merchant.id), params: @product_hash
      }.must_differ "Product.count", 0

      must_respond_with :bad_request
    end
  end
end