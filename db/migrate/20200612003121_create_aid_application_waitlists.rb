class CreateAidApplicationWaitlists < ActiveRecord::Migration[6.0]
  def change
    create_view :aid_application_waitlists
  end
end
