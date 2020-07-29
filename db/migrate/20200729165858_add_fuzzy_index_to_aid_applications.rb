class AddFuzzyIndexToAidApplications < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :aid_applications, :name, using: :gist, opclass: :gist_trgm_ops, algorithm: :concurrently
    add_index :aid_applications, :street_address, using: :gist, opclass: :gist_trgm_ops, algorithm: :concurrently
  end
end
