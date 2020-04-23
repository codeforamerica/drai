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
