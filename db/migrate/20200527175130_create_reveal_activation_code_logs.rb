class CreateRevealActivationCodeLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :reveal_activation_code_logs do |t|
      t.references :aid_application, foreign_key: true, index: true
      t.references :user, foreign_key: true, index: true
    end
  end
end
