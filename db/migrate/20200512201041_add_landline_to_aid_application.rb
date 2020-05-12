class AddLandlineToAidApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_applications, :landline, :boolean
  end
end
