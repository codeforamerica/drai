class CreateMembers < ActiveRecord::Migration[6.0]
  def change
    create_table :members do |t|
      t.timestamps

      t.text :name
      t.date :birthday
      t.references :aid_application, foreign_key: true, index: true, null: true
    end
  end
end
