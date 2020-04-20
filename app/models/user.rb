# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :string           default(""), not null
#  encrypted_password     :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  name                   :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  organization_id        :bigint
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_organization_id       (organization_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable

  belongs_to :organization, optional: true, counter_cache: true

  validates :password, presence: true, on: :account_setup, unless: :password_present?

  def status
    if confirmed_at.blank?
      :invited
    elsif encrypted_password.blank?
      :confirmed
    else
      :active
    end
  end

  def status_human
    {
      invited: 'Invited',
      confirmed: 'Confirmed',
      active: 'Active',
    }.fetch(status)
  end

  def password_required?
    if encrypted_password.present? || (encrypted_password_changed? && encrypted_password_was.present?) || !password.nil?
      super
    else
      false
    end
  end

  def password_present?
    encrypted_password.present? || !password.nil?
  end

  def setup?
    encrypted_password.present?
  end
end
