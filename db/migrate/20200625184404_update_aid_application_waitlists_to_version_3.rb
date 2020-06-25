class UpdateAidApplicationWaitlistsToVersion3 < ActiveRecord::Migration[6.0]
  def change
    update_view :aid_application_waitlists, version: 3, revert_to_version: 2, materialized: true
  end
end
