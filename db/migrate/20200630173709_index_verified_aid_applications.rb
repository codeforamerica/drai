class IndexVerifiedAidApplications < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :aid_applications, [:organization_id, :submitted_at], where: "(verified_photo_id = true AND verified_proof_of_address = true AND verified_covid_impact = true)", name: "index_aid_applications_org_id_submitted_at_when_verified", algorithm: :concurrently
  end
end
