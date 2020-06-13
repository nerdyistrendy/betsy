require "test_helper"

describe CategoriesController do
  describe "Logged in Merchants" do
    before do
      perform_login
    end

    describe "new" do
      it "can get the new_category_path" do
        get new_category_path
        must_respond_with :success
      end
    end

    describe "create" do
      before do
        @category_hash = {
          category: {
            name: "Phoenix"
          }
        }
      end

      it "can create a new category" do
        expect {
          post categories_path, params: @category_hash
        }.must_differ 'Category.count', 1
    
        must_respond_with  :redirect
        expect(Category.last.name).must_equal @category_hash[:category][:name]
      end
  
      it "will not create a book with invalid params" do
        @category_hash[:category][:name] = nil
  
        expect {
          post categories_path, params: @category_hash
        }.wont_change "Category.count"
  
        must_respond_with :bad_request
      end
    end

    
  end

  describe "Guest Users" do
    describe "new" do
      it "cannot access the new_category_path and will be redirected" do
        get new_category_path
        must_respond_with :redirect
        expect(flash[:warning]).must_equal "You must be logged in to view this section"
      end
    end

    describe "create" do
      before do
        @category_hash = {
          category: {
            name: "Phoenix"
          }
        }
      end

      it "cannot create a new category and will be redirected" do
        expect {
          post categories_path, params: @category_hash
        }.wont_change 'Category.count'
    
        must_respond_with  :redirect
        expect(flash[:warning]).must_equal "You must be logged in to view this section"
      end
    end
  end
end
