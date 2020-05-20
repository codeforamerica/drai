class AddSubmittedAtIndexToAidApplications < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :aid_applications, [:organization_id, :submitted_at, :approved_at], name: 'index_aid_applications_org_id_submitted_at_approved_at', algorithm: :concurrently
    add_index :aid_applications, [:organization_id, :approved_at, :disbursed_at], name: 'index_aid_applications_org_id_approved_at_disbursed_at', algorithm: :concurrently
    add_index :aid_applications, [:organization_id, :disbursed_at], name: 'index_aid_applications_org_id_disbursed_at', algorithm: :concurrently
  end
end
