# == Schema Information
#
# Table name: users
#
#  id                               :bigint           not null, primary key
#  admin                            :boolean          default(FALSE), not null
#  aid_applications_approved_count  :bigint           default(0), not null
#  aid_applications_count           :integer          default(0), not null
#  aid_applications_created_count   :bigint           default(0), not null
#  aid_applications_submitted_count :bigint           default(0), not null
#  confirmation_sent_at             :datetime
#  confirmation_token               :string
#  confirmed_at                     :datetime
#  current_sign_in_at               :datetime
#  current_sign_in_ip               :inet
#  deactivated_at                   :datetime
#  email                            :string           default(""), not null
#  encrypted_password               :string
#  last_sign_in_at                  :datetime
#  last_sign_in_ip                  :inet
#  name                             :string
#  remember_created_at              :datetime
#  reset_password_sent_at           :datetime
#  reset_password_token             :string
#  sign_in_count                    :integer          default(0), not null
#  supervisor                       :boolean          default(FALSE), not null
#  unconfirmed_email                :string
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  inviter_id                       :bigint
#  organization_id                  :bigint
#
# Indexes
#
#  index_users_on_confirmation_token                         (confirmation_token) UNIQUE
#  index_users_on_deactivated_at_and_id                      (deactivated_at,id)
#  index_users_on_email                                      (email) UNIQUE
#  index_users_on_inviter_id                                 (inviter_id)
#  index_users_on_organization_id                            (organization_id)
#  index_users_on_organization_id_and_deactivated_at_and_id  (organization_id,deactivated_at DESC,id DESC)
#  index_users_on_reset_password_token                       (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (inviter_id => users.id)
#  fk_rails_...  (organization_id => organizations.id)
#
class User < ApplicationRecord
  PASSWORD_REGEX = /\A(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,70}\z/

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :confirmable,
         :database_authenticatable,
         :recoverable,
         :timeoutable,
         :trackable

  has_paper_trail

  belongs_to :organization, optional: true, counter_cache: true
  belongs_to :inviter, class_name: 'User', optional: true
  has_many :aid_applications_created, class_name: 'AidApplication', inverse_of: :creator, foreign_key: :creator_id
  has_many :aid_applications_submitted, class_name: 'AidApplication', inverse_of: :submitter, foreign_key: :submitted_id
  has_many :aid_applications_approved, class_name: 'AidApplication', inverse_of: :approver, foreign_key: :approver_id
  has_many :aid_applications_disbursed, class_name: 'AidApplication', inverse_of: :disburser, foreign_key: :disburser_id
  has_many :aid_applications_unpaused, class_name: 'AidApplication', inverse_of: :unpauser, foreign_key: :unpauser_id
  has_many :aid_applications_rejected, class_name: 'AidApplication', inverse_of: :rejecter, foreign_key: :rejecter_id

  scope :activated, -> { where(deactivated_at: nil) }
  scope :deactivated, -> { where.not(deactivated_at: nil) }
  scope :supervisor, -> { where(supervisor: true) }

  validates :email, presence: true, email: true, uniqueness: { case_sensitive: false }
  validates :password, confirmation: true, format: { with: PASSWORD_REGEX, message: :password_complexity }, if: :password_required?
  validates :password, presence: true, on: :account_setup, unless: :password_present?

  validates :admin, inclusion: { in: [false] }, if: -> { organization.present? }
  validates :supervisor, inclusion: { in: [false] }, if: -> { organization.blank? }
  validates :organization, presence: true, unless: :admin?

  def status
    if deactivated_at.present?
      :deactivated
    elsif confirmed_at.blank?
      :invited
    elsif encrypted_password.blank?
      :confirmed
    else
      :active
    end
  end

  def status_human
    {
      deactivated: 'Deactivated',
      invited: 'Invited',
      confirmed: 'Confirmed',
      active: 'Active',
    }.fetch(status)
  end

  def password_required?
    !(password.nil? && password_confirmation.nil?)
  end

  def password_present?
    encrypted_password.present? || !password.nil?
  end

  def setup?
    encrypted_password.present?
  end

  def active_for_authentication?
    super && deactivated_at.blank?
  end

  # Message when deactivated account attempts sign in
  def inactive_message
    deactivated_at.present? ? 'Account has been deactivated' : super
  end

  def assister?
    !admin && !supervisor
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
