class RelateProductToReview < ActiveRecord::Migration[6.0]
  def change
    add_reference :reviews, :product, index: true
  end
end
