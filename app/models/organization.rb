# == Schema Information
#
# Table name: organizations
#
#  id                     :bigint           not null, primary key
#  aid_applications_count :integer          default(0), not null
#  name                   :text             not null
#  users_count            :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class Organization < ApplicationRecord
  has_many :users
  has_many :aid_applications
end
