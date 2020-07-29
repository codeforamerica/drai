class CreateIgnoredDuplicates < ActiveRecord::Migration[6.0]
  def change
    create_table :ignored_duplicates do |t|
      t.timestamps

      t.references :aid_application, foreign_key: { on_delete: :cascade }, index: true
      t.references :duplicate_aid_application, foreign_key: { to_table: :aid_applications, on_delete: :cascade }, index: { name: 'index_ignored_duplicates_on_duplicate_id' }

      t.references :user, foreign_key: true, index: true, null: true

      t.index [:aid_application_id, :duplicate_aid_application_id], unique: true, name: 'index_ignored_duplicates_on_both_ids'
    end
  end
end
