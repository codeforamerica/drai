class UpdateAidApplicationSearchesToVersion5 < ActiveRecord::Migration[6.0]
  def change
    update_view :aid_application_searches, version: 5, revert_to_version: 4, materialized: true
  end
end
