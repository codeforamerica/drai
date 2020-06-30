class AddVerificationsToAidApplications < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_applications, :verified_photo_id, :boolean
    add_column :aid_applications, :verified_proof_of_address, :boolean
    add_column :aid_applications, :verified_covid_impact, :boolean
    add_column :aid_applications, :verification_case_note, :text
  end
end
