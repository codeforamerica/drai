class CreateMessageLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :message_logs do |t|
      t.timestamps

      t.text :message_id
      t.text :channel
      t.text :from
      t.text :to
      t.text :subject
      t.text :body
      t.text :status
      t.text :status_code
      t.text :status_message
      t.text :messageable_type
      t.bigint :messageable_id

      t.index :message_id, unique: true
      t.index [:messageable_type, :messageable_id]
    end
  end
end
