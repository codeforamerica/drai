class AddConfirmedInvalidPhoneNumberToAidApplications < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_applications, :confirmed_invalid_phone_number, :boolean
  end
end
