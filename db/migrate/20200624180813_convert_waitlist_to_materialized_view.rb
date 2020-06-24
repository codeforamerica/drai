class ConvertWaitlistToMaterializedView < ActiveRecord::Migration[6.0]
  def change
    reversible do |dir|
      dir.up do
        drop_view :aid_application_waitlists
        create_view :aid_application_waitlists, version: 2, materialized: true

        add_index :aid_application_waitlists, :aid_application_id, unique: true
        add_index :aid_application_waitlists, [:organization_id, :aid_application_id], name: :index_aid_application_waitlists_on_org_id_and_app_id
        add_index :aid_application_waitlists, [:organization_id, :county_name], name: :index_aid_application_waitlists_on_org_id_and_county
      end

      dir.down do
        drop_view :aid_application_waitlists, materialized: true
        create_view :aid_application_waitlists, version: 2
      end
    end
  end
end
