require "test_helper"

describe HomepagesController do
  describe "index" do
    it "can get the homepages path" do
      get root_path

      must_respond_with :success
    end
  end
end