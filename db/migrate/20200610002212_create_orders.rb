class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.string :name
      t.string :email
      t.string :mailing_address
      t.string :cc_name
      t.string :cc_cvv
      t.string :cc_number
      t.date :cc_exp
      t.string :zipcode
      t.string :status

      t.timestamps
    end
  end
end
