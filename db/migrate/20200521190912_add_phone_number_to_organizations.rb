class AddPhoneNumberToOrganizations < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :contact_information, :string
  end
end
