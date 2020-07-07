# == Schema Information
#
# Table name: aid_applications
#
#  id                                  :bigint           not null, primary key
#  allow_mailing_address               :boolean
#  apartment_number                    :text
#  application_number                  :string
#  approved_at                         :datetime
#  attestation                         :boolean
#  birthday                            :date
#  card_receipt_method                 :text
#  city                                :text
#  contact_method_confirmed            :boolean
#  country_of_origin                   :text
#  county_name                         :string
#  covid19_care_facility_closed        :boolean
#  covid19_caregiver                   :boolean
#  covid19_experiencing_symptoms       :boolean
#  covid19_reduced_work_hours          :boolean
#  covid19_underlying_health_condition :boolean
#  email                               :text
#  email_consent                       :boolean
#  gender                              :text
#  landline                            :boolean
#  mailing_apartment_number            :text
#  mailing_city                        :text
#  mailing_state                       :text
#  mailing_street_address              :text
#  mailing_zip_code                    :text
#  name                                :text
#  no_cbo_association                  :boolean
#  phone_number                        :text
#  preferred_language                  :text
#  racial_ethnic_identity              :string           default([]), is an Array
#  receives_calfresh_or_calworks       :boolean
#  sexual_orientation                  :text
#  sms_consent                         :boolean
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
#  approver_id                         :bigint
#  creator_id                          :bigint           not null
#  organization_id                     :bigint           not null
#  submitter_id                        :bigint
#
# Indexes
#
#  index_aid_applications_on_application_number  (application_number) UNIQUE
#  index_aid_applications_on_approver_id         (approver_id)
#  index_aid_applications_on_creator_id          (creator_id)
#  index_aid_applications_on_organization_id     (organization_id)
#  index_aid_applications_on_submitter_id        (submitter_id)
#
# Foreign Keys
#
#  fk_rails_...  (approver_id => users.id)
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (submitter_id => users.id)
#
class AidApplication < ApplicationRecord
  PAUSE_INTERVAL = 12.days
  READONLY_ONCE_SET = ['application_number']
  DEMOGRAPHIC_OPTIONS_DEFAULT = 'Decline to state'.freeze
  PREFERRED_LANGUAGE_OPTIONS = [
    'American Sign Language',
    '​Amharic​​​​​',
    'Arabic',
    '​Armenian',
    '​Assyrian​​​​​',
    '​Bengali​​​​​',
    '​Burmese​​​​​',
    '​Cambodian',
    'Cantonese',
    'English',
    'Farsi',
    'French',
    'Gujarati',
    'Hebrew',
    'Hindi',
    '​Ilocano',
    'Italian',
    'Japanese',
    'Kanjobal',
    'Korean',
    'Lao',
    'Mam',
    'Mandarin',
    'Mien',
    'Mixteco',
    'Pashtu',
    'Polish',
    'Portuguese',
    'Punjabi',
    '​Romanian',
    'Russian',
    'Samoan',
    'Spanish',
    'Tagalog',
    'Thai',
    'Tigrigna',
    'Turkic',
    'Turkish',
    'Triqui',
    'Urdu',
    'Vietnamese',
    'Zapoteco',
    'Other Non-English',
    'Other Sign Language',
    'Other',
    DEMOGRAPHIC_OPTIONS_DEFAULT
  ].freeze

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

  CARD_RECEIPT_OPTIONS = [
    CARD_RECEIPT_PICK_UP = "pick_up".freeze,
    CARD_RECEIPT_DELIVER = "deliver_in_person".freeze,
    CARD_RECEIPT_MAIL = "mail".freeze,
    CARD_RECEIPT_DECIDE_LATER = "decide_later".freeze
  ].freeze

  LOCALE_LANGUAGE_MAPPING = {
    "en" => 'English',
    "zh" => 'Mandarin',
    "ar" => 'Arabic',
    "vi" => 'Vietnamese',
    "ko" => 'Korean',
    "tl" => 'Tagalog',
    "es" => 'Spanish'
  }.freeze

  has_paper_trail

  scope :visible, -> { where.not(submitted_at: nil) }
  scope :committed, -> { visible.unrejected.unwaitlisted }
  scope :submitted, -> { where.not(submitted_at: nil) }
  scope :verified, -> { where(verified_photo_id: true, verified_proof_of_address: true, verified_covid_impact: true) }
  scope :unverified, -> { where(verified_photo_id: [nil, false], verified_proof_of_address: [nil, false], verified_covid_impact: [nil, false]) }
  scope :approved, -> { where.not(approved_at: nil) }
  scope :unapproved, -> { where(approved_at: nil) }
  scope :disbursed, -> { where.not(disbursed_at: nil) }
  scope :undisbursed, -> { where(disbursed_at: nil) }
  scope :paused, -> { where.not(paused_at: nil) }
  scope :unpaused, -> { where(paused_at: nil) }
  scope :rejected, -> { where.not(rejected_at: nil) }
  scope :unrejected, -> { where(rejected_at: nil) }
  scope :waitlisted, -> { left_joins(:aid_application_waitlist).where.not(aid_application_waitlists: { waitlist_position: nil }) }
  scope :unwaitlisted, -> { left_joins(:aid_application_waitlist).where(aid_application_waitlists: { waitlist_position: nil }) }

  scope :only_submitted, -> { submitted.unverified.unpaused.unapproved.unwaitlisted.unrejected }
  scope :only_verified, -> { verified.unapproved }
  scope :only_approved, -> { approved.undisbursed }
  scope :only_disbursed, -> { disbursed }
  scope :only_paused, -> { paused }
  scope :only_rejected, -> { rejected }
  scope :only_waitlisted, -> { visible.unrejected.waitlisted }

  scope :query, (lambda do |input|
    if input.strip.starts_with?('APP-')
      where(application_number: input)
    else
      potential_phone_number = input.gsub(/\D/, '')
      phone_number_search = potential_phone_number.size == 10
      search_term = phone_number_search ? potential_phone_number : input

      select('"aid_applications".*').joins(:aid_application_search)
        .merge(AidApplicationSearch.search(search_term, true, 'search_rank'))
    end
  end)

  scope :filter_by_params, (lambda do |params|
    filter_query = self

    if params[:q].present?
      filter_query = filter_query.query(params[:q])
    end

    if params[:status].in? ['submitted', 'verified', 'approved', 'disbursed', 'paused', 'rejected', 'waitlisted']
      status = params[:status]
      filter_query = filter_query.send("only_#{status}")
    else
      status = 'submitted'
    end

    if params[:order].in? ['desc', 'asc']
      order = params[:order]
    else
      order = 'desc'
    end

    if status == 'waitlisted'
      filter_query = filter_query.order("aid_application_waitlists.waitlist_position" => order)
    elsif status == 'verified'
      filter_query = filter_query.order("submitted_at" => order)
    else
      filter_query = filter_query.order("#{status}_at" => order)
    end

    filter_query
  end)

  scope :matching_submitted_apps, ->(aid_application) do
    submitted
      .where.not(id: aid_application.id)
      .where(
        birthday: aid_application.birthday,
        zip_code: aid_application.zip_code.strip
      )
      .match_by_address(aid_application)
      .fuzzy_search(aid_application.name)
  end

  scope :match_by_address, ->(aid_application) do
    result = all.fuzzy_search(aid_application.street_address)

    if aid_application.apartment_number.present?
      result = result.where("#{normalize_sql('apartment_number')} = #{normalize_sql('?')}", aid_application.apartment_number)
    end

    result
  end

  scope :matching_approved_apps, ->(aid_application) do
    approved.matching_submitted_apps(aid_application)
  end

  belongs_to :organization, counter_cache: true
  belongs_to :creator, class_name: 'User', inverse_of: :aid_applications_created, counter_cache: :aid_applications_created_count
  belongs_to :submitter, class_name: 'User', inverse_of: :aid_applications_submitted, counter_cache: :aid_applications_submitted_count, optional: :true
  belongs_to :verifier, class_name: 'User', inverse_of: :aid_applications_verified, counter_cache: :aid_applications_verified_count, optional: :true
  belongs_to :approver, class_name: 'User', inverse_of: :aid_applications_approved, counter_cache: :aid_applications_approved_count, optional: :true
  belongs_to :disburser, class_name: 'User', inverse_of: :aid_applications_disbursed, counter_cache: :aid_applications_disbursed_count, optional: :true
  belongs_to :unpauser, class_name: 'User', inverse_of: :aid_applications_unpaused, counter_cache: :aid_applications_unpaused_count, optional: :true
  belongs_to :rejecter, class_name: 'User', inverse_of: :aid_applications_rejected, counter_cache: :aid_applications_rejected_count, optional: :true

  has_one :payment_card
  has_one :aid_application_search
  has_one :aid_application_waitlist
  has_many :message_logs, as: :messageable

  delegate :waitlist_position, to: :aid_application_waitlist, allow_nil: true

  enum preferred_contact_channel: { text: "text", voice: "voice", email: "email" }, _prefix: "preferred_contact_channel"

  auto_strip_attributes :email,
                        :phone_number,
                        :preferred_language,
                        :country_of_origin,
                        :racial_ethnic_identity,
                        :sexual_orientation,
                        :gender,
                        :name,
                        :street_address,
                        :zip_code,
                        :apartment_number

  before_validation :strip_phone_number
  before_validation :sms_consent_only_if_not_landline
  before_validation :ensure_county_matches_zip_code

  validates :application_number, uniqueness: true, allow_nil: true

  with_options on: :eligibility do
    validates :valid_work_authorization, inclusion: { in: [false], message: :eligibility_criteria }
    validate :eligibility_required
    validates :no_cbo_association, inclusion: { in: [true], message: :confirmation_required }
    validates :county_name, inclusion: { in: -> (aid_application) { aid_application.organization.county_names }, message: :county_required }
  end

  with_options on: [:submit, :contact_information] do
    validates :phone_number, presence: true, phone_number: true
    validates :email, presence: true, if: -> { email_consent? }
    validates :email, email: { message: :email }, if: -> { email.present? }
  end

  with_options on: :submit do
    validates :name, presence: true
    validates :birthday, presence: true, inclusion: { in: -> (_member) { '01/01/1900'.to_date..18.years.ago }, message: :birthday }
    validates :racial_ethnic_identity, presence: true

    validates :street_address, presence: true
    validates :city, presence: true
    validates :zip_code, presence: true, zip_code: true
    validate :zip_code_must_be_in_organization_service_area

    with_options if: :allow_mailing_address? do
      validates :mailing_street_address, presence: true
      validates :mailing_city, presence: true
      validates :mailing_state, presence: true
      validates :mailing_zip_code, presence: true, five_digit_zip: true
    end

    # TODO: add a presence check to `email` attribute once email_consent is fully deprecated
    validates :email_consent, presence: true, unless: -> { sms_consent? }
    validates :email, mailgun_email: true, if: -> { email.present? && !confirmed_invalid_email? }

    validates :phone_number, twilio_phone_number: true, if: -> { phone_number.present? && sms_consent? && !confirmed_invalid_phone_number? }

    validates :receives_calfresh_or_calworks, inclusion: { in: [true, false], message: :check_one_box_eligible }
    validate :unmet_needs_required
    validates :attestation, inclusion: { in: [true], message: :attestation_required }
  end

  with_options on: :confirmation do
    validates :contact_method_confirmed, inclusion: { in: [true], message: :confirmation_required }
    validates :card_receipt_method, inclusion: { in: CARD_RECEIPT_OPTIONS, message: :required_question }
  end

  with_options if: :submitted_at do
    validates :application_number, presence: true
    validates :submitter, presence: true
  end
  validates :submitted_at, presence: true, if: :application_number

  with_options if: :approved_at do
    validates :approver, presence: true
  end

  with_options if: :disbursed_at do
    validates :disburser, presence: true
  end

  alias_attribute :text_phone_number, :phone_number
  alias_attribute :voice_phone_number, :phone_number

  # https://shift.infinite.red/fast-csv-report-generation-with-postgres-in-rails-d444d9b915ab?source=post_page-----c4b7bc112049----------------------
  def self.stream_rows(raw_sql, options = "WITH CSV HEADER")
    conn = ActiveRecord::Base.connection.raw_connection
    conn.copy_data "COPY (#{raw_sql}) TO STDOUT #{options};" do
      while row = conn.get_copy_data
        yield row
      end
    end
  end

  def self.normalize_sql(value)
    "regexp_replace(lower(unaccent(trim(regexp_replace(#{value}, '\s+', ' ', 'g')))), '[^A-z0-9 ]', '')"
  end

  def self.delete_stale_and_unsubmitted
    apps_to_delete = AidApplication.where(submitted_at: nil).where('created_at < ?', 1.day.ago)
    apps_to_delete.destroy_all
  end


  def self.pause_stale_and_unapproved
    pausable = AidApplication.where(paused_at: nil, approved_at: nil, rejected_at: nil, unpaused_at: nil).where('submitted_at < ?', PAUSE_INTERVAL.ago)
    repausable = AidApplication.where(paused_at: nil, approved_at: nil, rejected_at: nil).where('unpaused_at < ?', PAUSE_INTERVAL.ago)
    pausable.or(repausable).find_each do |aid_application|
      aid_application.update!(paused_at: Time.current)
    rescue => e
      Raven.capture_exception(e)
    end
  end

  def text_phone_number=(value)
    self.phone_number = value if preferred_contact_channel_text?
  end

  def voice_phone_number=(value)
    self.phone_number = value if preferred_contact_channel_voice?
  end

  def phone_number=(value)
    super(value) if value.present?
  end

  def copy_phone_number_errors
    return if errors[:phone_number].empty?

    errors[:phone_number].each do |error|
      errors[:voice_phone_number] << error
      errors[:text_phone_number] << error
    end
  end

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

  def unmet_needs_required
    checked_an_option = [unmet_childcare, unmet_food, unmet_housing,
                         unmet_other, unmet_transportation, unmet_utilities].any?
    if !checked_an_option
      errors.add(:unmet_other, I18n.t('activerecord.errors.messages.check_one_box_eligible'))
    end
  end

  def zip_code_must_be_in_organization_service_area
    zip_code_counties = ZipCode.new(zip_code).counties
    if (organization.county_names & zip_code_counties).empty?
      zip_code_county_text = zip_code_counties.any? ? "#{zip_code_counties.first} County" : "another state"
      errors.add(:zip_code, :zip_code_outside_organization_service_area, zip_code: zip_code, zip_code_county: zip_code_county_text)
    end
  end

  def save_and_approve(approver:)
    assign_attributes(
      approved_at: Time.current,
      approver: approver,
      paused_at: nil
    )

    save!
  end

  def save_and_reject(rejecter:)
    assign_attributes(
      rejected_at: Time.current,
      rejecter: rejecter,
      paused_at: nil
    )

    save!
  end

  def record_verification_if_changed(verifier:)
    if verified_photo_id_changed? || verified_proof_of_address_changed? || verified_covid_impact_changed? || verification_case_note_changed?
      assign_attributes(
        verifier: verifier
      )
    end

    if verified? && (verified_photo_id_changed?(to: true) || verified_proof_of_address_changed?(to: true) || verified_covid_impact_changed?(to: true))
      assign_attributes(
        verified_at: Time.current,
      )
    elsif !verified?
      assign_attributes(
        verified_at: nil
      )
    end
  end

  def save_and_unpause(unpauser:)
    assign_attributes(
      paused_at: nil,
      unpaused_at: Time.current,
      unpauser: unpauser
    )

    save!
  end

  def generate_application_number
    loop do
      value = "APP-#{organization.id}-#{rand(100..999)}-#{rand(100..999)}"
      break(value) unless self.class.exists?(application_number: value)
    end
  end

  def send_submission_notification
    submission_message = organization.submission_instructions(application_number: application_number, county: county_name, locale: locale)

    if sms_consent?
      ApplicationTexter.with(messageable: self).basic_message(
        to: phone_number,
        body: I18n.t('text_message.subscribed', locale: locale),
      ).deliver_later

      ApplicationTexter.with(messageable: self).basic_message(
        to: phone_number,
        body: submission_message
      ).deliver_later
    end

    if email.present?
      ApplicationEmailer.with(messageable: self).basic_message(
        to: email,
        subject: I18n.t('email_message.application_number.subject', application_number: application_number, locale: locale),
        body: submission_message
      ).deliver_later
    end
  end

  def send_approval_notification
    if sms_consent?
      ApplicationTexter.with(messageable: self).basic_message(
        to: phone_number,
        body: I18n.t(
          'text_message.approved',
          locale: locale
        )
      ).deliver_later
    end

    if email.present?
      ApplicationEmailer.with(messageable: self).basic_message(
        to: email,
        subject: I18n.t('email_message.approved.subject', locale: locale),
        body: I18n.t('email_message.approved.body_html', locale: locale)
      ).deliver_later
    end
  end

  def send_disbursement_notification
    card_receipt_method_message = I18n.t(
      "shared.card_receipt_method_message.#{card_receipt_method}",
      locale: locale,
      default: ''
    )

    if sms_consent?
      ApplicationTexter.with(messageable: self).basic_message(
        to: phone_number,
        body: I18n.t(
          'text_message.activation',
          activation_code: payment_card.activation_code,
          ivr_phone_number: BlackhawkApi.ivr_phone_number,
          card_receipt_method_message: card_receipt_method_message,
          locale: locale
        )
      ).deliver_later
    end

    if email.present?
      ApplicationEmailer.with(messageable: self).basic_message(
        to: email,
        subject: I18n.t('email_message.activation.subject', locale: locale),
        body: I18n.t(
          'email_message.activation.body_html',
          activation_code: payment_card.activation_code,
          ivr_phone_number: BlackhawkApi.ivr_phone_number,
          card_receipt_method_message: card_receipt_method_message,
          locale: locale
        )
      ).deliver_later
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
    if disbursed?
      :disbursed
    elsif approved?
      :approved
    elsif rejected?
      :rejected
    elsif waitlisted?
      :waitlisted
    elsif paused?
      :paused
    elsif verified?
      :verified
    elsif submitted?
      :submitted
    else
      :started
    end
  end

  def status_human
    {
      started: 'Unsubmitted',
      submitted: 'Submitted',
      verified: 'Verified',
      approved: 'Approved',
      disbursed: 'Disbursed',
      paused: 'Paused',
      rejected: 'Rejected',
      waitlisted: "Waitlist ##{waitlist_position}"
    }.fetch(status)
  end

  def eligible?
    old_errors = errors.dup
    result = valid?(:eligibility)
    errors.clear
    errors.copy!(old_errors)
    result
  end

  def submitted?
    submitted_at.present?
  end

  def partially_verified?
    [verified_photo_id, verified_proof_of_address, verified_covid_impact, verification_case_note.present?].any?
  end

  def verified?
    [verified_photo_id, verified_proof_of_address, verified_covid_impact].all?
  end

  def waitlisted?
    return false unless waitlist_position.present?
    waitlist_position > 0
  end

  def approved?
    approved_at.present?
  end

  def paused?
    paused_at.present?
  end

  def rejected?
    rejected_at.present?
  end

  def disbursed?
    disbursed_at.present?
  end

  def disburse(payment_card, disburser:)
    payment_card.update!(
      activation_code: payment_card.generate_activation_code,
      aid_application: self
    )

    update!(
      disbursed_at: Time.current,
      disburser: disburser
    )
  end

  def documents_count
    [verified_photo_id, verified_proof_of_address, verified_covid_impact].count(&:present?)
  end

  def locale
    case preferred_language
    when "Spanish", "Kanjobal", "Mam", "Mixteco", "Triqui", "Zapoteco"
      "es"
    when "Cantonese"
      "zh"
    when "Mandarin"
      "zh"
    when "Arabic"
      "ar"
    when "Vietnamese"
      "vi"
    when "Korean"
      "ko"
    when "Tagalog"
      "tl"
    else
      "en"
    end
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

  def ensure_county_matches_zip_code
    zip_code_counties = ZipCode.new(zip_code).counties
    if !zip_code_counties.include?(county_name) && (organization.county_names & zip_code_counties).any?
      self.county_name = zip_code_counties.first
    end
  end

  def chir_app?
    organization.name == 'Coalition for Humane Immigrant Rights'
  end
end
