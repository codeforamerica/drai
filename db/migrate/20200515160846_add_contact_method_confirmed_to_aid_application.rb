class AddContactMethodConfirmedToAidApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_applications, :contact_method_confirmed, :boolean
  end
end
