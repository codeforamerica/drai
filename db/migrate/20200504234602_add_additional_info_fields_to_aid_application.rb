class AddAdditionalInfoFieldsToAidApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_applications, :receives_calfresh_or_calworks, :boolean
    add_column :aid_applications, :unmet_food, :boolean
    add_column :aid_applications, :unmet_housing, :boolean
    add_column :aid_applications, :unmet_childcare, :boolean
    add_column :aid_applications, :unmet_utilities, :boolean
    add_column :aid_applications, :unmet_transportation, :boolean
    add_column :aid_applications, :unmet_other, :boolean
  end
end
