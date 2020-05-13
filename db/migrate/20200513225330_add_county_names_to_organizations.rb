class AddCountyNamesToOrganizations < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :county_names, :string, array: true
  end
end
