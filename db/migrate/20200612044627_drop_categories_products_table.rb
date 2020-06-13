class DropCategoriesProductsTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :categories_products_joins do |t|
      t.bigint "category_id"
      t.bigint "product_id"
      t.index ["category_id"], name: "index_categories_products_joins_on_category_id"
      t.index ["product_id"], name: "index_categories_products_joins_on_product_id"
    end
  end
end
