class CreateAidApplicationSearches < ActiveRecord::Migration[6.0]
  def change
    create_view :aid_application_searches, materialized: true

    add_index :aid_application_searches, :aid_application_id, unique: true
    add_index "aid_application_searches", "to_tsvector('english'::regconfig, searchable_data)", name: "index_aid_application_searches_on_searchable_data", using: :gin
  end
end
