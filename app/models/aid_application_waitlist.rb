class AidApplicationWaitlist < ApplicationRecord
  belongs_to :aid_application
  belongs_to :organization

  def self.refresh(concurrently: true)
    Scenic.database.refresh_materialized_view(table_name, concurrently: concurrently, cascade: false)
  end
end
