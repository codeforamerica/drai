class AddUniqueIdentifierToAidApplications < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_applications, :submitted_at, :datetime
    add_reference :aid_applications, :submitter, foreign_key: { to_table: :users }, index: true, null: true
    add_column :aid_applications, :application_number, :string
    add_index :aid_applications, :application_number, unique: true
  end
end
