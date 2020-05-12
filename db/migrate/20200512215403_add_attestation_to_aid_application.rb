class AddAttestationToAidApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_applications, :attestation, :boolean
  end
end
