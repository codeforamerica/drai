class AddPreferredContactModeToAidApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_applications, :preferred_contact_channel, :string
  end
end
