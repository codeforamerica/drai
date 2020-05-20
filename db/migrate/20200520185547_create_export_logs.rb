class CreateExportLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :export_logs do |t|
      t.timestamps
      t.references :organization, foreign_key: true, index: true
      t.references :exporter, foreign_key: { to_table: :users }, index: true
    end
  end
end
