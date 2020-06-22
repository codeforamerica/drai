class UpdateAidApplicationWaitlistsToVersion2 < ActiveRecord::Migration[6.0]
  def change
    update_view :aid_application_waitlists, version: 2, revert_to_version: 1
  end
end
