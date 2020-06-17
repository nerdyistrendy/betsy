require "test_helper"

describe ProductsController do
  before do
    @blacksmith_test = merchants(:blacksmith)
    @weavery_test = merchants(:weavery)
    @food_test = categories(:food)
    @pickles_test = products(:pickles)
    @tent_test = products(:tent)
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

    @update_hash = {
      product: {
        description: "One jar of homegrown, brined pickles.",
        inventory: 50,
        price: 6
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
    
    describe "edit" do
      it "will redirect a guest user to root" do 
        get edit_product_path(@pickles_test.id)

        must_respond_with :redirect
        must_redirect_to root_path
      end 
    end

    describe "update" do
      it "will redirect a guest user" do 
        patch product_path(@pickles_test.id), params:@update_hash

        must_respond_with :redirect
        expect(@pickles_test.description).must_equal "One jar of homegrown pickles."
        expect(@pickles_test.price).must_equal 2
        expect(@pickles_test.inventory).must_equal 40
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

      it "will redirect if not authorized user" do
        get new_merchant_product_path(@weavery_test.id)

        must_respond_with :redirect
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

      it "will redirect for unauthorized merchant" do
        post merchant_products_path(@weavery_test.id), params: @product_hash
    
        must_respond_with :redirect
        must_redirect_to root_path
      end
    end

    describe "edit" do
      it "will retrieve the edit page for an authorized user" do
        get edit_product_path(@pickles_test.id)

        must_respond_with :success
      end

      it "cannot edit an invalid product" do 
        get edit_product_path(-5)

        must_respond_with :redirect 
        must_redirect_to root_path
        expect(flash[:error]).must_equal "Invalid Product"
      end 

      it "will redirect for unauthorized user" do
        get edit_product_path(@tent_test.id)

        must_respond_with :redirect 
        must_redirect_to product_path(@tent_test.id)
        expect(flash[:error]).must_equal "You are not authorized to edit that product."
      end
    end

    describe "update" do 
      it "can update a product" do
        product = @pickles_test
        patch product_path(product.id), params:@update_hash
        
        product.reload

        expect(product.description).must_equal @update_hash[:product][:description]
        expect(product.price).must_equal @update_hash[:product][:price]
        expect(product.inventory).must_equal @update_hash[:product][:inventory]
      end

      it "does not update a product with invalid params" do
        before_product = 
        bad_params = @update_hash
        bad_params[:product][:name] = nil
        patch product_path(@pickles_test.id), params: bad_params

        must_respond_with :bad_request
        expect(flash[:error]).must_equal "Product could not be updated."
      end

      it "does not update another merchant's products" do
        patch product_path(@tent_test.id), params:@update_hash

        must_respond_with :redirect
        expect(flash[:error]).must_equal "You are not authorized to edit that product."
      end

      it "does not update an invalid product" do
        patch product_path(-5), params:@update_hash

        must_respond_with :redirect
        expect(flash[:error]).must_equal "Invalid Product"
      end
    end 

    describe "destroy" do 
      it "successfully deletes and redirects to merchant's products path" do
        expect {
          delete product_path(@pickles_test.id)
        }.must_differ "Product.count", -1

        must_respond_with :redirect
        must_redirect_to merchant_path(@blacksmith_test)
        expect(flash[:success]).must_equal "Product successfully deleted."
      end

      # it "redirects for an item that could not be deleted" do 
      #   expect {
      #     delete product_path()
      #   }.wont_differ "Product.count"

      #   must_respond_with :bad_request
      #   expect(flash[:error]).must_equal "Product could not be deleted."
      # end 

      it "redirect for invalid product" do
        delete product_path(-5)

        must_respond_with :redirect
        must_redirect_to root_path
        expect(flash[:error]).must_equal "Invalid Product"
      end

      it "will redirect an unauthorized merchant" do
        delete product_path(@tent_test.id)

        must_respond_with :redirect
        must_redirect_to root_path
        expect(flash[:error]).must_equal "You are not authorized to complete this action"
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