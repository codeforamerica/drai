class RemoveMembersCountFromAidApplications < ActiveRecord::Migration[6.0]
  def change
    remove_column :aid_applications, :members_count
  end
end
