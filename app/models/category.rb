class Category < ApplicationRecord
 has_and_belongs_to_many :products  

  def active_products
    return self.products.where(active: true)
  end
end
