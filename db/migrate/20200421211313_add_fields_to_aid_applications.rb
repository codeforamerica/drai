class AddFieldsToAidApplications < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_applications, :street_address, :text
    add_column :aid_applications, :city, :text
    add_column :aid_applications, :zip_code, :text
    add_column :aid_applications, :phone_number, :text
    add_column :aid_applications, :email, :text
  end
end
