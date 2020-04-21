class AddUsersToOrganizations < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :organization, foreign_key: true, index: true, null: true
    add_column :organizations, :users_count, :integer, null: false, default: 0
  end
end
