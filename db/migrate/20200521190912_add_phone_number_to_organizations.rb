class AddPhoneNumberToOrganizations < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :phone_number, :string
  end
end
