class ExportLog < ApplicationRecord
  belongs_to :organization
  belongs_to :exporter, class_name: 'User'
end
