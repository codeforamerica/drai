class RenameUniqueIdentifierToApplicationNumberOnAidApplications < ActiveRecord::Migration[6.0]
  def change
    rename_column :aid_applications, :unique_identifier, :application_number
  end
end
