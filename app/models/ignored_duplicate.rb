class IgnoredDuplicate < ApplicationRecord
  belongs_to :aid_application
  belongs_to :duplicate_aid_application, class_name: 'AidApplication'
  belongs_to :user, optional: true
end
