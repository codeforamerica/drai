class AddCardReceiptMethodToAidApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_applications, :card_receipt_method, :text
  end
end
