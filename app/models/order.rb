class Order < ApplicationRecord
  has_many :order_items
  validates :name, :email, :mailing_address, :cc_name, :cc_cvv, :cc_exp, :cc_number, :zipcode, :status, presence: true
  validates :email, format: { with: /\w+@\w+\.\w+/, message: "Please enter valid email address" }
  validates :cc_cvv, :cc_number, :zipcode, numericality: { only_integer: true }
  validates :cc_number, length: {is: 15}
  validates :cc_cvv, length: {is: 3}
  validates :zipcode, length: {is: 5}

end
