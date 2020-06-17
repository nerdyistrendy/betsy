require "test_helper"

describe ProductsController do
  before do
    @blacksmith_test = merchants(:blacksmith)
    @food_test = categories(:food)
    @pickles_test = products(:pickles)
    @inactive_pickles_test = products(:inactive_pickles)
    @inactive_tent_test = products(:inactive_tent)

    @product_hash = {
      product: {
        name: "Crisp Pickles",
        description: "One jar of homegrown pickles.",
        img_url: "yourmom.com/image.jpeg",
        inventory: 40,
        price: 2,
        category_ids: [categories(:food).id, categories(:lifestyle).id]
      }
    }
  end
  describe "Guest Users" do
    describe "index" do
      it "can get the products path" do
        get products_path

        must_respond_with :success
      end

      it "can get the nested merchant products path of a valid merchant" do
        get merchant_products_path(@blacksmith_test.id)
        
        must_respond_with :success
      end

      it "will redirect to merchants index for an invalid merchant products path" do
        get merchant_products_path(-5)
        
        must_respond_with :redirect
        must_redirect_to merchants_path
      end

      it "can get the nested category products path" do
        get category_products_path(@food_test.id)
        
        must_respond_with :success
      end

      it "will redirect to categories index for an invalid category products path" do
        get category_products_path(-5)
        
        must_respond_with :redirect
        must_redirect_to categories_path
      end
    end

    describe "show" do
      it "will get show for valid ids" do
        valid_product = products(:tent)
    
        get "/products/#{valid_product.id}"
    
        must_respond_with :success
      end
    
      it "will respond with not_found for invalid ids" do
        invalid_product_id = -5
    
        get "/products/#{invalid_product_id}"
    
        must_respond_with :not_found
      end
    end
  
    describe "new" do
      it "will redirect to the root if merchant isn't logged in" do
        get new_merchant_product_path(@blacksmith_test.id)

        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "create" do
      it "will redirect to root for unauthenticated user" do
        post merchant_products_path(@blacksmith_test.id), params: @product_hash

        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "toggle_active" do
      it "will redirect to root if used by unauthenticated user" do
        patch toggle_active_path(@pickles_test.id)

        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "will not toggle active if merchant not logged in" do
        before_state = @pickles_test.active
  
        patch toggle_active_path(@pickles_test.id)
        @pickles_test.reload
  
        expect(@pickles_test.active).must_equal before_state
      end
    end
    
    describe 'cart' do
      before do
        @product = products(:pickles)
        @quantity = 2 
      end
      it "can add a product to the seassion[:cart] hash" do
        patch product_cart_path(@product.id), params:{"quantity": @quantity}

        expect(session[:cart].class).must_equal Hash
        expect(session[:cart].count).must_equal 1
        expect(session[:cart]["#{@product.id}"]).must_equal @quantity
      end

      it "will not let you add product to the cart if product has no inventory" do
        @product.inventory = 0
        @product.save
        patch product_cart_path(@product.id), params:{"quantity": @quantity}
    
        
        must_respond_with :bad_request
        expect(session[:cart].count).must_equal 0
      end

      it "will not let you add product to the cart if quantity > inventory" do
        @product.inventory = 1
        @product.save
        patch product_cart_path(@product.id), params:{"quantity": @quantity}
    
        
        must_respond_with :bad_request
        expect(session[:cart].count).must_equal 0
      end
    end

    describe 'updatequant' do
      before do
        @product = products(:pickles)
        @quantity = 2 
        patch product_cart_path(@product.id), params:{"quantity": @quantity}
      end
      it "can update product quantity sesssion[:cart] hash" do
        patch product_update_quant_path(@product.id), params:{"quantity": 4}

        expect(session[:cart].class).must_equal Hash
        expect(session[:cart].count).must_equal 1
        expect(session[:cart]["#{@product.id}"]).must_equal 4
      end

      it "will not let you update quantity to the cart if product has no inventory" do
        @product.inventory = 0
        @product.save
        patch product_update_quant_path(@product.id), params:{"quantity": 4}
    
        must_redirect_to order_cart_path
        expect(session[:cart].count).must_equal 1
        expect(session[:cart]["#{@product.id}"]).must_equal @quantity
      end

      it "will not let you add product to the cart if quantity > inventory" do
        @product.inventory = 1
        @product.save
        patch product_update_quant_path(@product.id), params:{"quantity": 4}
    
        must_redirect_to order_cart_path
        expect(session[:cart].count).must_equal 1
        expect(session[:cart]["#{@product.id}"]).must_equal @quantity
      end
    end

    describe 'remove_from_cart' do
      before do
        @product = products(:pickles)
        @quantity = 2 
        patch product_cart_path(@product.id), params:{"quantity": @quantity}

        @product2 = products(:tent)
        @quantity2 = 1 
        patch product_cart_path(@product2.id), params:{"quantity": @quantity2}
      end
      it "can remove product from session[:cart] hash" do
        expect(session[:cart].class).must_equal Hash
        expect(session[:cart].count).must_equal 2
        expect(session[:cart]["#{@product.id}"]).must_equal @quantity
        expect(session[:cart]["#{@product2.id}"]).must_equal @quantity2

        patch product_remove_cart_path(@product.id)
        expect(session[:cart].count).must_equal 1
        expect(session[:cart]["#{@product.id}"]).must_be_nil
        expect(session[:cart]["#{@product2.id}"]).must_equal @quantity2
      end
    end
  end
  
  describe "Logged In Merchants" do
    before do
      perform_login(@blacksmith_test)
    end
    
    describe "new" do
      it "can get the new_merchant_product_path" do
        get new_merchant_product_path(@blacksmith_test.id)

        must_respond_with :success
      end
    end

    
   
    describe "create" do
      it "will redirect to merchant dashboard after creating a product" do
        post merchant_products_path(@blacksmith_test.id), params: @product_hash
    
        must_respond_with :redirect
        must_redirect_to merchant_path(@blacksmith_test.id)
      end
      
      it "can create a product with categories with logged in user" do
        expect {
          post merchant_products_path(@blacksmith_test.id), params: @product_hash
        }.must_differ 'Product.count', 1

        expect(Product.last.name).must_equal @product_hash[:product][:name]
        expect(Product.last.description).must_equal @product_hash[:product][:description]
        expect(Product.last.img_url).must_equal @product_hash[:product][:img_url]
        expect(Product.last.active).must_equal true
        expect(Product.last.inventory).must_equal @product_hash[:product][:inventory]
        expect(Product.last.price).must_equal @product_hash[:product][:price]
        expect(Product.last.merchant).wont_be_nil
        expect(Product.last.merchant.username).must_equal @blacksmith_test.username

        expect(Product.last.categories).wont_be_nil
        expect(Product.last.categories).wont_be_empty
        expect(Product.last.categories).must_include @food_test
      end
    
      it "can create a product without categories with logged in user" do
        @product_hash[:product][:category_ids] = []

        expect {
          post merchant_products_path(@blacksmith_test.id), params: @product_hash
        }.must_differ 'Product.count', 1
    
        expect(Product.last.name).must_equal @product_hash[:product][:name]
        expect(Product.last.description).must_equal @product_hash[:product][:description]
        expect(Product.last.img_url).must_equal @product_hash[:product][:img_url]
        expect(Product.last.active).must_equal true
        expect(Product.last.inventory).must_equal @product_hash[:product][:inventory]
        expect(Product.last.price).must_equal @product_hash[:product][:price]
        expect(Product.last.merchant).wont_be_nil
        expect(Product.last.merchant.username).must_equal @blacksmith_test.username

        expect(Product.last.categories).wont_be_nil
        expect(Product.last.categories).must_be_empty
      end
      
      it "will respond with bad request and not add a product if given invalid params" do
        @product_hash[:product][:name] = nil

        expect {
          post merchant_products_path(@blacksmith_test.id), params: @product_hash
        }.must_differ "Product.count", 0

        must_respond_with :bad_request
      end
    end

    describe "toggle_active" do
      it "will redirect to the merchant dashboard" do
        merchant_product = @blacksmith_test.products.first

        patch toggle_active_path(merchant_product.id)
  
        must_respond_with :redirect
        must_redirect_to merchant_path(@blacksmith_test.id)
      end

      it "will change an active product to inactive" do
        before_state = @pickles_test.active
  
        patch toggle_active_path(@pickles_test.id)
        @pickles_test.reload

        expect(@pickles_test.active).must_equal !before_state
      end
  
      it "will change an inactive product to active" do
        before_state = @inactive_pickles_test.active
  
        patch toggle_active_path(@inactive_pickles_test.id)
        @inactive_pickles_test.reload

        expect(@inactive_pickles_test.active).must_equal !before_state
      end

      it "will redirect to root path if merchant doesn't own said product" do
        patch toggle_active_path(@inactive_tent_test.id)
  
        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "will redirect to root path if product is invalid" do
        patch toggle_active_path(-5)
  
        must_redirect_to root_path
      end

      it "will not toggle active if logged in merchant doesn't own said product" do
        before_state = @inactive_tent_test.active

        patch toggle_active_path(@inactive_tent_test.id)
        @inactive_tent_test.reload
  
        expect(@inactive_tent_test.active).must_equal before_state
      end
    end
  end
end