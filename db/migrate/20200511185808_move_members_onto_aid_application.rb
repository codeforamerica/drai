class MoveMembersOntoAidApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_applications, :name, :text
    add_column :aid_applications, :birthday, :date
    add_column :aid_applications, :preferred_language, :text
    add_column :aid_applications, :country_of_origin, :text
    add_column :aid_applications, :racial_ethnic_identity, :text
    add_column :aid_applications, :sexual_orientation, :text
    add_column :aid_applications, :gender, :text

    update_view :aid_application_searches, version: 3, revert_to_version: 2, materialized: true

    drop_table :members
  end
end
