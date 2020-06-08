class AddPausedAtToAidApplications < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_applications, :paused_at, :datetime
  end
end
