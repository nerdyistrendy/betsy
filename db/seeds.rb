# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'

MERCHANT_FILE = Rails.root.join('db', 'merchants.csv')
puts "Loading raw driver data from #{MERCHANT_FILE}"

merchant_failures = []
CSV.foreach(MERCHANT_FILE, :headers => true) do |row|
  merchant = Merchant.new
  merchant.id = row['id']
  merchant.username = row['username']
  merchant.email = row['email']
  successful = merchant.save
  if !successful
    merchant_failures << merchant
    puts "Failed to save merchant: #{merchant.inspect}"
  else
    puts "Created merchant: #{merchant.inspect}"
  end
end

puts "Added #{Merchant.count} merchant records"
puts "#{merchant_failures.length} merchants failed to save"

PRODUCT_FILE = Rails.root.join('db', 'products.csv')
puts "Loading raw product data from #{PRODUCT_FILE}"

product_failures = []
CSV.foreach(PRODUCT_FILE, :headers => true) do |row|
  product = Product.new
  product.name = row['name']
  product.id = row['id']
  product.merchant_id = row['merchant_id']
  product.inventory = row['inventory']
  product.price = row['price']
  product.description = row['description']
  product.img_url = row['img_url']
  product.active = row['active']
  successful = product.save
  if !successful
    product_failures << product
    puts "Failed to save products: #{product.inspect}"
  else
    puts "Created products: #{product.inspect}"
  end
end

puts "Added #{Product.count} product records"
puts "#{product_failures.length} products failed to save"

# ORDER_ITEM_FILE = Rails.root.join('db', 'orderitems.csv')
# puts "Loading raw order item data from #{ORDER_ITEM_FILE}"

# order_item_failures = []
# CSV.foreach(ORDER_ITEM_FILE, :headers => true) do |row|
#   order_item = OrderItem.new
#   order_item.quantity = row['quantity']
#   order_item.status = row['status']
#   order_item.merchant_id = row['merchant_id']
#   order_item.product_id = row['product_id']
#   order_item.order_id = row['order_id']
#   order_item.id = row['id']
#   puts "trying to save order items: #{order_item.inspect}"
#   if !Order.find_by(id: order_item.order_id)
#     new_order = Order.new
#     new_order.save
#   end
#   successful = order_item.save!
#   if !successful
#     order_item_failures << order_item
#     puts "Failed to save order items: #{order_item.inspect}"
#   else
#     puts "Created order items: #{order_item.inspect}"
#   end
# end

# puts "Added #{OrderItem.count} order item records"
# puts "#{order_item_failures.length} order items failed to save"


ActiveRecord::Base.connection.tables.each do |t|
  ActiveRecord::Base.connection.reset_pk_sequence!(t)
end 