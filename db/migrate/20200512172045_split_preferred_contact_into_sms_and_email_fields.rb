class SplitPreferredContactIntoSmsAndEmailFields < ActiveRecord::Migration[6.0]
  def change
    remove_column :aid_applications, :preferred_contact_channel, :string
    add_column :aid_applications, :sms_consent, :boolean
    add_column :aid_applications, :email_consent, :boolean
  end
end
