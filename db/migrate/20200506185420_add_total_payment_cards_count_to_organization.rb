class AddTotalPaymentCardsCountToOrganization < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :total_payment_cards_count, :integer, null: false, default: 0
    ActiveRecord::Base.connection.execute("UPDATE organizations SET total_payment_cards_count = 10")
  end
end
