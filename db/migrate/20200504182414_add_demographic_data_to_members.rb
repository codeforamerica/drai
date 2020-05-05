class AddDemographicDataToMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :members, :preferred_language, :text
    add_column :members, :country_of_origin, :text
    add_column :members, :racial_ethnic_identity, :text
    add_column :members, :sexual_orientation, :text
    add_column :members, :gender, :text
  end
end
