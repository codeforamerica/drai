# == Schema Information
#
# Table name: aid_applications
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  assister_id     :bigint           not null
#  organization_id :bigint           not null
#
# Indexes
#
#  index_aid_applications_on_assister_id      (assister_id)
#  index_aid_applications_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (assister_id => users.id)
#  fk_rails_...  (organization_id => organizations.id)
#
class AidApplication < ApplicationRecord
  belongs_to :organization, counter_cache: true
  belongs_to :assister, class_name: 'User', counter_cache: true
end
