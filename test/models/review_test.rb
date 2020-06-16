require "test_helper"

describe Review do
  before do
    @excitable_review_test = reviews(:excitable_pickle_review)
    @pickle_test = products(:pickles)
    @blacksmith_test = merchants(:blacksmith)
    @confused_review_test = products(:confused_pickle_review:)
  end

  describe "validations" do

  end
end
