class AidApplicationWaitlist < ApplicationRecord
  belongs_to :aid_application
  belongs_to :organization
end
