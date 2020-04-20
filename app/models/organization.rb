# == Schema Information
#
# Table name: organizations
#
#  id         :bigint           not null, primary key
#  name       :text             not null
#  user_count :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Organization < ApplicationRecord
  has_many :users
end
