# == Schema Information
#
# Table name: aid_applications
#
#  id                                  :bigint           not null, primary key
#  allow_mailing_address               :boolean
#  apartment_number                    :text
#  application_number                  :string
#  birthday                            :date
#  city                                :text
#  country_of_origin                   :text
#  covid19_care_facility_closed        :boolean
#  covid19_caregiver                   :boolean
#  covid19_experiencing_symptoms       :boolean
#  covid19_reduced_work_hours          :boolean
#  covid19_underlying_health_condition :boolean
#  email                               :text
#  gender                              :text
#  mailing_apartment_number            :text
#  mailing_city                        :text
#  mailing_state                       :text
#  mailing_street_address              :text
#  mailing_zip_code                    :text
#  name                                :text
#  phone_number                        :text
#  preferred_contact_channel           :string
#  preferred_language                  :text
#  racial_ethnic_identity              :string           is an Array
#  receives_calfresh_or_calworks       :boolean
#  sexual_orientation                  :text
#  street_address                      :text
#  submitted_at                        :datetime
#  unmet_childcare                     :boolean
#  unmet_food                          :boolean
#  unmet_housing                       :boolean
#  unmet_other                         :boolean
#  unmet_transportation                :boolean
#  unmet_utilities                     :boolean
#  valid_work_authorization            :boolean
#  zip_code                            :text
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  creator_id                          :bigint           not null
#  organization_id                     :bigint           not null
#  submitter_id                        :bigint
#
# Indexes
#
#  index_aid_applications_on_application_number  (application_number) UNIQUE
#  index_aid_applications_on_creator_id          (creator_id)
#  index_aid_applications_on_organization_id     (organization_id)
#  index_aid_applications_on_submitter_id        (submitter_id)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (submitter_id => users.id)
#
class AidApplication < ApplicationRecord
  READONLY_ONCE_SET = ['application_number', 'submitted_at', 'submitter_id']
  DEMOGRAPHIC_OPTIONS_DEFAULT = 'Decline to state'.freeze
  COUNTRY_OF_ORIGIN_OPTIONS = [
    'Afghanistan',
    'Argentina',
    'Armenia',
    'Bangladesh',
    'Brazil',
    'Cambodia',
    'China, People\'s Republic',
    'Colombia',
    'Ecuador',
    'Egypt',
    'El Salvador',
    'Ethiopia',
    'Guatemala',
    'Honduras',
    'India',
    'Indonesia',
    'Iran',
    'Iraq',
    'Korea, South',
    'Laos',
    'Malaysia',
    'Mexico',
    'Myanmar',
    'Nepal',
    'Nicaragua',
    'Pakistan',
    'Peru',
    'Philippines',
    'Russia',
    'Taiwan',
    'Thailand',
    'Ukraine',
    'Vietnam',
    'Other',
    DEMOGRAPHIC_OPTIONS_DEFAULT
  ].freeze

  RACIAL_OR_ETHNIC_IDENTITY_OPTIONS = [
    DEMOGRAPHIC_OPTIONS_DEFAULT,
    'American Indian or Alaska Native',
    'Asian Indian',
    'Black or African American (Hispanic or Latino)',
    'Black or African American (non-Hispanic or Latino)',
    'Cambodian',
    'Chinese',
    'Filipino',
    'Guamanian',
    'Hmong',
    'Indigenous - Latin America',
    'Japanese',
    'Korean',
    'Laotian',
    'Native Hawaiian',
    'Vietnamese',
    'Other Asian',
    'Thai',
    'Samoan',
    'White (Hispanic or Latino)',
    'White (non-Hispanic or Latino)',
    'Hispanic or Latino (any other race)',
    'Other',
  ].freeze

  SEXUAL_ORIENTATION_OPTIONS = [
    'Straight or heterosexual',
    'Bisexual',
    'Gay or lesbian',
    'Queer',
    'Another sexual orientation',
    'Unknown',
    DEMOGRAPHIC_OPTIONS_DEFAULT
  ].freeze

  GENDER_OPTIONS = [
    'Male',
    'Female',
    'Non-Binary (neither male nor female)',
    'Transgender: Female to Male',
    'Transgender: Male to Female',
    'Another gender identity',
    DEMOGRAPHIC_OPTIONS_DEFAULT
  ].freeze


  scope :submitted, -> { where.not(submitted_at: nil) }

  belongs_to :organization, counter_cache: true
  belongs_to :creator, class_name: 'User', inverse_of: :aid_applications_created, counter_cache: :aid_applications_created_count
  belongs_to :submitter, class_name: 'User', inverse_of: :aid_applications_submitted, counter_cache: :aid_applications_submitted_count, optional: :true
  has_one :aid_application_search

  scope :query, ->(term) { select('"aid_applications".*').joins(:aid_application_search).merge(AidApplicationSearch.search(term)) }

  enum preferred_contact_channel: { text: "text", voice: "voice", email: "email" }, _prefix: "preferred_contact_channel"

  auto_strip_attributes :email,
                        :preferred_language,
                        :country_of_origin,
                        :racial_ethnic_identity,
                        :sexual_orientation,
                        :gender

  before_validation :strip_phone_number
  before_validation :sms_consent_only_if_not_landline

  validates :application_number, uniqueness: true, allow_nil: true

  with_options on: :eligibility do
    validates :valid_work_authorization, inclusion: { in: [false], message: :eligibility_criteria}
    validate :eligibility_required
  end
  with_options on: :submit do
    validates :name, presence: true
    validates :birthday, presence: true, inclusion: { in: -> (_member) { '01/01/1900'.to_date..18.years.ago }, message: :birthday }
    validates :street_address, presence: true
    validates :city, presence: true
    validates :zip_code, presence: true, zip_code: true
    validates :mailing_zip_code, five_digit_zip: true

    validates :phone_number, presence: true, phone_number: true
    validates :email, presence: true, email: { message: :email }, if: -> { email_consent? }
    validates :email_consent, presence: true, unless: -> { sms_consent? }

    validates :receives_calfresh_or_calworks, inclusion: { in: [true, false] }
    validates :racial_ethnic_identity, presence: true
    validates :attestation, inclusion: { in: [true], message: :attestation }
  end


  with_options if: :submitted_at do
    validates :application_number, presence: true
    validates :submitter, presence: true
  end
  validates :submitted_at, presence: true, if: :application_number

  def save_and_submit(submitter:)
    transaction(joinable: false, requires_new: true) do
      if errors.empty? && valid?(:submit)
        self.submitter = submitter
        self.application_number = generate_application_number
        self.submitted_at = Time.current

        save(context: :submit)
      else
        save
        valid?(:submit)
      end
    end
  end

  def eligibility_required
    checked_an_option = [covid19_care_facility_closed, covid19_caregiver, covid19_experiencing_symptoms,
                         covid19_reduced_work_hours, covid19_underlying_health_condition].any?
    if !checked_an_option
      errors.add(:covid19_caregiver, I18n.t('activerecord.errors.messages.check_one_box_eligible'))
    end
  end

  def generate_application_number
    loop do
      value = "APP-#{organization.id}-#{rand(100..999)}-#{rand(100..999)}"
      break(value) unless self.class.exists?(application_number: value)
    end
  end

  def readonly_attribute?(name)
    if name.in? READONLY_ONCE_SET
      attribute_was(name).present?
    else
      super
    end
  end

  def status
    if submitted?
      :submitted
    else
      :started
    end
  end

  def status_human
    {
      started: 'Started',
      submitted: 'Submitted',
    }.fetch(status)
  end

  def submitted?
    submitted_at.present?
  end

  private

  def strip_phone_number
    return if phone_number.blank?

    self.phone_number = phone_number.gsub(/\D/, '')
    if phone_number.size == 11 && phone_number.first == '1'
      self.phone_number = phone_number.slice(1..-1)
    end
  end

  def sms_consent_only_if_not_landline
    if sms_consent? && landline?
      self.sms_consent = false
    end
  end
end
