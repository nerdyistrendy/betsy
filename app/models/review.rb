class Review < ApplicationRecord
  belongs_to :product

  validates :text, presence: true, length: { in: 1..1000 }
  validates :rating, presence: true, numericality: { only_integer: true }
  validates :reviewer, presence: true, length: { in: 1..30 }
  validates_associated :product
end
