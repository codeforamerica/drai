class UpdateAddressFieldsOnAidApplications < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_applications, :apartment_number, :text

    add_column :aid_applications, :allow_mailing_address, :boolean
    add_column :aid_applications, :mailing_street_address, :text
    add_column :aid_applications, :mailing_apartment_number, :text
    add_column :aid_applications, :mailing_city, :text
    add_column :aid_applications, :mailing_state, :text
    add_column :aid_applications, :mailing_zip_code, :text
  end
end
