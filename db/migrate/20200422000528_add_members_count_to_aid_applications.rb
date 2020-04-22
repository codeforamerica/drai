class AddMembersCountToAidApplications < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_applications, :members_count, :integer, null: false, default: 0
  end
end
