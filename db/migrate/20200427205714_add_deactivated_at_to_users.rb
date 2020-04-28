class AddDeactivatedAtToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :deactivated_at, :datetime

    add_index :users, [:organization_id, :deactivated_at, :id], order: { deactivated_at: :desc, id: :desc }
    add_index :users, [:deactivated_at, :id], order: { deactivated_at: :desc, id: :desc }
  end
end
