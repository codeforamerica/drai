class AddNoCboAssociationToAidApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_applications, :no_cbo_association, :boolean
  end
end
