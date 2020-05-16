class CreatePaymentCard < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_cards do |t|
      t.timestamps

      t.string :quote_number
      t.string :sequence_number
      t.string :proxy_number
      t.string :card_number
      t.string :client_order_number
      t.string :activation_code
      t.datetime :activation_code_assigned_at

      t.references :aid_application, foreign_key: true, index: { unique: true }, null: true

      t.index :sequence_number, unique: true
      t.index :proxy_number, unique: true
    end

    add_column :aid_applications, :disbursed_at, :datetime
    add_reference :aid_applications, :disburser, foreign_key: { to_table: :users }, index: true, null: true
    add_column :users, :aid_applications_disbursed_count, :bigint, default: 0, null: false
  end
end
