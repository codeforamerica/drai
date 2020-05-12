class AddApprovalFieldsToAidApplications < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_applications, :approved_at, :datetime
    add_reference :aid_applications, :approver, foreign_key: { to_table: :users }, index: true, null: true
    add_column :users, :aid_applications_approved_count, :bigint, default: 0, null: false
  end
end
