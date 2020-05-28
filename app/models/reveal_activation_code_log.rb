class RevealActivationCodeLog < ApplicationRecord
  belongs_to :aid_application
  belongs_to :user
end
