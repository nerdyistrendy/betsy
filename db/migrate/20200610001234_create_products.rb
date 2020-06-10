class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.string :name
      t.integer :inventory
      t.float :price
      t.text :description
      t.string :img_url

      t.timestamps
    end
  end
end
