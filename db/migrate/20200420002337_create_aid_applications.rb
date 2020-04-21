class CreateAidApplications < ActiveRecord::Migration[6.0]
  def change
    create_table :aid_applications do |t|
      t.timestamps

      t.references :organization, foreign_key: true, index: true, null: false
      t.references :assister, foreign_key: { to_table: :users }, index: true, null: false
    end

    add_column :organizations, :aid_applications_count, :integer, null: false, default: 0
    add_column :users, :aid_applications_count, :integer, null: false, default: 0
  end
end
