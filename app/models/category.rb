class Category < ApplicationRecord
  has_and_belongs_to_many :products  

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def active_products
    return self.products.where(active: true)
  end
end
