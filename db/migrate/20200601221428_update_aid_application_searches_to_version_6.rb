class UpdateAidApplicationSearchesToVersion6 < ActiveRecord::Migration[6.0]
  def change
    update_view :aid_application_searches, version: 6, revert_to_version: 5, materialized: true
  end
end
