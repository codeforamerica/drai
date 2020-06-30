class CreatePaymentCardOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_card_orders do |t|
      t.timestamps

      t.string :client_order_number
      t.references :organization, foreign_key: true, index: true, null: true
    end
  end
end
