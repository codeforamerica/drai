class ChangeAssistersToCreatorsOnAidApplications < ActiveRecord::Migration[6.0]
  def change
    user_id = User.first.id

    reversible do |dir|
      dir.up do
        add_reference :aid_applications, :creator, foreign_key: { to_table: :users }, index: true, null: true
        ActiveRecord::Base.connection.execute("UPDATE aid_applications SET creator_id = COALESCE(assister_id, #{user_id})")
        change_column_null(:aid_applications, :creator_id, false)

        remove_reference :aid_applications, :assister, foreign_key: { to_table: :users }, index: true, null: true
      end

      dir.down do
        add_reference :aid_applications, :assister, foreign_key: { to_table: :users }, index: true, null: true
        ActiveRecord::Base.connection.execute("UPDATE aid_applications SET assister_id = creator_id")
        remove_reference :aid_applications, :creator, foreign_key: { to_table: :users }, index: true, null: true
      end
    end
  end
end
