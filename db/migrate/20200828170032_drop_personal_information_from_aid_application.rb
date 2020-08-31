class DropPersonalInformationFromAidApplication < ActiveRecord::Migration[6.0]
  def change
    remove_column :aid_applications, :street_address
    remove_column :aid_applications, :city
    remove_column :aid_applications, :name
    remove_column :aid_applications, :apartment_number
    remove_column :aid_applications, :mailing_street_address
    remove_column :aid_applications, :mailing_apartment_number
    remove_column :aid_applications, :mailing_city
    remove_column :aid_applications, :mailing_state
    remove_column :aid_applications, :mailing_zip_code
    remove_column :aid_applications, :contact_method_confirmed
    remove_column :aid_applications, :confirmed_invalid_email
    remove_column :aid_applications, :confirmed_invalid_phone_number
    remove_column :aid_applications, :created_at
    remove_column :aid_applications, :updated_at
  end
end
