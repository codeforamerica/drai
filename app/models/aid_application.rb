# == Schema Information
#
# Table name: aid_applications
#
#  id                 :bigint           not null, primary key
#  application_number :string
#  city               :text
#  email              :text
#  members_count      :integer          default(0), not null
#  phone_number       :text
#  street_address     :text
#  submitted_at       :datetime
#  zip_code           :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  creator_id         :bigint           not null
#  organization_id    :bigint           not null
#  submitter_id       :bigint
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
  
  scope :submitted, -> { where.not(submitted_at: nil) }

  belongs_to :organization, counter_cache: true
  belongs_to :creator, class_name: 'User', inverse_of: :aid_applications_created, counter_cache: :aid_applications_created_count
  belongs_to :submitter, class_name: 'User', inverse_of: :aid_applications_submitted, counter_cache: :aid_applications_submitted_count, optional: :true
  has_many :members, -> { order(created_at: :asc) }
  has_one :aid_application_search

  accepts_nested_attributes_for :members, allow_destroy: true
  scope :query, ->(term) { select('"aid_applications".*').joins(:aid_application_search).merge(AidApplicationSearch.search(term)) }

  enum preferred_contact_channel: { text: "text", voice: "voice", email: "email" }, _prefix: "preferred_contact_channel"

  auto_strip_attributes :email
  before_validation :strip_phone_number
  after_validation :copy_phone_number_errors

  validates :application_number, uniqueness: true, allow_nil: true

  with_options on: :submit do
    validates :street_address, presence: true
    validates :city, presence: true
    validates :zip_code, presence: true, zip_code: true

    validates :preferred_contact_channel, presence: true
    validates :phone_number, presence: true, phone_number: true, if: -> { preferred_contact_channel_text? || preferred_contact_channel_voice? }
    validates :email, presence: true, email: { message: "Make sure to enter a valid email" }, if: -> { preferred_contact_channel_email? }

    validates :receives_calfresh_or_calworks, presence: true

    validates :members, length: { minimum: 1, maximum: 2 }
  end

  with_options if: :submitted_at do
    validates :application_number, presence: true
    validates :submitter, presence: true
  end
  validates :submitted_at, presence: true, if: :application_number

  alias_attribute :text_phone_number, :phone_number
  alias_attribute :voice_phone_number, :phone_number

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

  def member_names
    members.map(&:name)
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
end
