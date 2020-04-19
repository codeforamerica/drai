class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable

  validates :password, presence: true, on: :account_setup, unless: :password_present?

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
