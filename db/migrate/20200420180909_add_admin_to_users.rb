class AddAdminToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :admin, :boolean, null: false, default: false

    User.where(organization: nil).update_all(admin: true)
  end
end
