require "test_helper"

describe Category do
  before do
    @food_test = categories(:food)
    @pickle_test = products(:pickles)
  end
  
  describe "active_products" do
    it "will retrieve all products where active is true" do
      products_arr = @food_test.active_products

      expect(products_arr).must_include @pickle_test
      products_arr.each do |p|
        expect(p.active).must_equal true
      end
    end

    it "will ignore inactive products" do
      inactive_pickle = products(:inactive_pickles)
      products_arr = @food_test.active_products

      expect(products_arr).wont_include inactive_pickle
    end
  end

  describe "validations" do
    before do
      @new_cat = Category.new(name: "Spiritual Support")
    end

    it "is valid when the name field is present and unique" do
      expect(@new_cat.valid?).must_equal true
    end

    it "is invalid when the name field is missing" do
      @new_cat.name = nil  

      expect(@new_cat.valid?).must_equal false
      expect(@new_cat.errors.messages).must_include :name
      expect(@new_cat.errors.messages[:name]).must_equal ["can't be blank"]
    end

    it "is invalid with a non-unique name, case-insensitive" do
      @new_cat.save!
      other_cat = Category.new(name: "Spiritual Support")
      upcase_cat = Category.new(name: "SPIRITUAL SUPPORT")
 
      expect(other_cat.valid?).must_equal false
      expect(other_cat.errors.messages).must_include :name
      expect(other_cat.errors.messages[:name]).must_equal ["has already been taken"]

      expect(upcase_cat.valid?).must_equal false
      expect(upcase_cat.errors.messages).must_include :name
      expect(upcase_cat.errors.messages[:name]).must_equal ["has already been taken"]
    end
  end

  describe "relations" do
    before do
      @pickle_test = products(:pickles)
      @tent_test = products(:tent)
      @lifestyle = categories(:lifestyle)
    end

    it "has and belongs to many products " do
      @lifestyle.products << @tent_test
      expect(@lifestyle.products).wont_be_empty
      expect(@lifestyle.products).must_include @tent_test
      expect(@tent_test.categories).must_include @lifestyle

      @lifestyle.products << @pickle_test
      expect(@lifestyle.products).must_include @pickle_test
      expect(@pickle_test.categories).must_include @lifestyle
    end
  end
end
