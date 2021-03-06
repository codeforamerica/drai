class AddUnpausedToAidApplications < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_applications, :unpaused_at, :timestamp
    add_reference :aid_applications, :unpauser, foreign_key: { to_table: :users }, index: true, null: true
    add_column :users, :aid_applications_unpaused_count, :bigint, default: 0, null: false
  end
end
