class IndexBirthdayAndZipcodeOnAidApplications < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :aid_applications, [:zip_code, :birthday], algorithm: :concurrently
  end
end
