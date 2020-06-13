class Product < ApplicationRecord
  has_and_belongs_to_many :categories 
  belongs_to :merchant
  has_many :order_items
  has_many :reviews

  validates :name, presence: true, length: { in: 1..100 }
  validates :description, presence: true, length: { maximum: 500 }
  validates :inventory, presence: true, numericality: { only_integer: true }
  validates :price, presence: true, numericality: true
  validates :img_url, presence: true
  validates_associated :categories

  def self.cart_total_items(session)
    total = 0
    item_count = session[:cart].values
    item_count.each do |num|
      total += num.to_i
    end

    return total
  end

  def self.subtotal(session)
    subtotal = 0
    session[:cart].each do |product_id, quant|
      @product = Product.find_by(id: product_id)
      subtotal += @product.price * quant.to_i
    end
    return subtotal
  end

  def self.active_products
    return Product.all.where(active: true)
  end
  
end
