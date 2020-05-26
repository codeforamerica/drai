class MessageLog < ApplicationRecord
  TWILIO_STATUSES = %w[
    queued
    accepted
    sending
    sent
    delivered
    undelivered
    failed
  ].freeze

  MAILGUN_STATUSES = %w[
    delivered
    opened
    failed
  ].freeze

  STATUSES = (TWILIO_STATUSES + MAILGUN_STATUSES).uniq

  belongs_to :messageable, polymorphic: true, optional: true

  def self.find_or_create_by_message_id(message_id)
    attempts ||= 1
    find_or_create_by(message_id: message_id)
  rescue ActiveRecord::RecordNotUnique
    attempts += 1
    retry if attempts <= 2
  end

  def self.has_updated_status?(old_status, new_status)
    old_index = STATUSES.index(old_status.try(:downcase))
    new_index = STATUSES.index(new_status.try(:downcase))

    return true unless old_index
    return unless new_index

    new_index >= old_index
  end

  def assign_status(status:, status_code: nil, status_message: nil)
    return unless self.class.has_updated_status?(self.status, status)

    self.status = status
    self.status_code = status_code if status_code.present?
    self.status_message = status_message if status_message.present?

    self
  end
end

