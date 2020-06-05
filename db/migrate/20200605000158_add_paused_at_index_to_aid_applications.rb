class AddPausedAtIndexToAidApplications < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :aid_applications, [:organization_id, :submitted_at, :paused_at], name: 'index_aid_applications_org_id_submitted_at_paused_at', algorithm: :concurrently
  end
end
