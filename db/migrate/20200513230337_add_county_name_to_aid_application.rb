class AddCountyNameToAidApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_applications, :county_name, :string
  end
end
