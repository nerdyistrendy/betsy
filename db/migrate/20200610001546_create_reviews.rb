class CreateReviews < ActiveRecord::Migration[6.0]
  def change
    create_table :reviews do |t|
      t.text :text
      t.integer :rating
      t.string :reviewer

      t.timestamps
    end
  end
end
