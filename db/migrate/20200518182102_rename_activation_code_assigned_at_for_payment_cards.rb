class RenameActivationCodeAssignedAtForPaymentCards < ActiveRecord::Migration[6.0]
  def change
    rename_column :payment_cards, :activation_code_assigned_at, :blackhawk_activation_code_assigned_at
  end
end
