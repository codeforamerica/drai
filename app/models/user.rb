class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable

  def password_required?
    super if encrypted_password.present? || (encrypted_password_changed? && encrypted_password_was.present?) || !password.nil?
  end

  def password_present?
    encrypted_password.present? || !password.nil?
  end
end
