# == Schema Information
#
# Table name: aid_application_searches
#
#  searchable_data    :text
#  aid_application_id :bigint
#
# Indexes
#
#  index_aid_application_searches_on_aid_application_id  (aid_application_id) UNIQUE
#  index_aid_application_searches_on_searchable_data     (to_tsvector('english'::regconfig, searchable_data)) USING gin
#
class AidApplicationSearch < ApplicationRecord
  extend Textacular

  belongs_to :aid_application

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end

  private

  def readonly?
    true
  end
end
