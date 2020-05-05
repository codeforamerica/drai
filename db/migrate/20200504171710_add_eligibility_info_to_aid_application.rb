class AddEligibilityInfoToAidApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_applications, :valid_work_authorization, :boolean
    add_column :aid_applications, :covid19_reduced_work_hours, :boolean
    add_column :aid_applications, :covid19_care_facility_closed, :boolean
    add_column :aid_applications, :covid19_experiencing_symptoms, :boolean
    add_column :aid_applications, :covid19_underlying_health_condition, :boolean
    add_column :aid_applications, :covid19_caregiver, :boolean
  end
end
