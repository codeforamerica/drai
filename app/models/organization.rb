# == Schema Information
#
# Table name: organizations
#
#  id                        :bigint           not null, primary key
#  aid_applications_count    :integer          default(0), not null
#  county_names              :string           default([]), is an Array
#  name                      :text             not null
#  total_payment_cards_count :integer          default(0), not null
#  users_count               :integer          default(0), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
class Organization < ApplicationRecord
  has_paper_trail

  has_many :users
  has_many :aid_applications

  scope :with_counts, lambda {
    select <<~SQL
      organizations.*,
      (
        SELECT COUNT(aid_applications.id)
        FROM aid_applications
        WHERE
          organization_id = organizations.id AND
          submitted_at IS NOT NULL
      ) AS submitted_aid_applications_count
    SQL
  }

  def submitted_aid_applications_count
    @submitted_aid_applications_count ||= attributes["submitted_aid_applications_count"] || aid_applications.submitted.count
  end
end
