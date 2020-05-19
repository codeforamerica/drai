class AddConfirmedInvalidEmailToAidApplications < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_applications, :confirmed_invalid_email, :boolean
  end
end
