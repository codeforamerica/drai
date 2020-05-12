class ChangeRacialEthnicIdentityTypeToArray < ActiveRecord::Migration[6.0]
  def change
    remove_column :aid_applications, :racial_ethnic_identity, :text
    add_column :aid_applications, :racial_ethnic_identity, :string, array: true
  end
end
