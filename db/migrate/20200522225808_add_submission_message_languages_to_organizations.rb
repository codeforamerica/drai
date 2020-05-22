class AddSubmissionMessageLanguagesToOrganizations < ActiveRecord::Migration[6.0]
  def change
    add_column :organizations, :submission_message_en, :text
    add_column :organizations, :submission_message_es, :text
    add_column :organizations, :submission_message_zh, :text
    add_column :organizations, :submission_message_ar, :text
    add_column :organizations, :submission_message_vi, :text
    add_column :organizations, :submission_message_ko, :text
    add_column :organizations, :submission_message_tl, :text
  end
end
