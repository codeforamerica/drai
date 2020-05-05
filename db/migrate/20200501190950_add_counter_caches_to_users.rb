class AddCounterCachesToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :aid_applications_created_count, :bigint, default: 0, null: false
    add_column :users, :aid_applications_submitted_count, :bigint, default: 0, null: false
  end
end
