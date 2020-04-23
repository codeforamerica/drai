# == Schema Information
#
# Table name: aid_applications
#
#  id              :bigint           not null, primary key
#  city            :text
#  email           :text
#  phone_number    :text
#  street_address  :text
#  zip_code        :text
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
  has_many :members, -> { order(created_at: :asc) }

  accepts_nested_attributes_for :members, allow_destroy: true, reject_if: :all_blank

  before_validation :strip_phone_number

  with_options on: :submit_aid_application do
    validates :street_address, presence: true
    validates :city, presence: true
    validates :zip_code, presence: true, zip_code: true

    validates :phone_number, presence: true, phone_number: true
    validates :email, presence: true, email: { message: "Make sure to enter a valid email" }

    validates :members, length: { minimum: 1, maximum: 2 }
  end

  private

  def strip_phone_number
    return if phone_number.blank?

    self.phone_number = phone_number.gsub(/\D/, '')
    if phone_number.size == 11 && phone_number.first == '1'
      self.phone_number = phone_number.slice(1..-1)
    end
  end
end
