class AddDefaultsToArrayStrings < ActiveRecord::Migration[6.0]
  def change
    change_column_default(:aid_applications, :racial_ethnic_identity, from: nil, to: [])
    change_column_default(:organizations, :county_names, from: nil, to: [])
  end
end
