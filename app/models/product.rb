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
end
