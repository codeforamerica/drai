# == Schema Information
#
# Table name: organizations
#
#  id                        :bigint           not null, primary key
#  aid_applications_count    :integer          default(0), not null
#  county_names              :string           default([]), is an Array
#  name                      :text             not null
#  total_payment_cards_count :integer          default(0), not null
#  users_count               :integer          default(0), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
class Organization < ApplicationRecord
  has_paper_trail

  has_many :users
  has_many :supervisors, -> { supervisor }, class_name: 'User'
  has_many :aid_applications

  scope :with_counts, lambda {
    select <<~SQL
      organizations.*,
      (
        SELECT COUNT(aid_applications.id)
        FROM aid_applications
        WHERE
          aid_applications.organization_id = organizations.id
          AND submitted_at IS NOT NULL
          AND paused_at IS NULL
          AND rejected_at IS NULL
      ) AS committed_aid_applications_count,
      (
        SELECT COUNT(aid_applications.id)
        FROM aid_applications
        WHERE
          aid_applications.organization_id = organizations.id 
          AND submitted_at IS NOT NULL
          AND paused_at IS NULL
          AND approved_at IS NULL
          AND rejected_at IS NULL
      ) AS submitted_aid_applications_count,
      (
        SELECT COUNT(aid_applications.id)
        FROM aid_applications
        WHERE
          organization_id = organizations.id
          AND paused_at IS NOT NULL
          AND rejected_at IS NULL
      ) AS paused_aid_applications_count,
      (
        SELECT COUNT(aid_applications.id)
        FROM aid_applications
        WHERE
          organization_id = organizations.id
          AND approved_at IS NOT NULL
          AND disbursed_at IS NULL
          AND rejected_at IS NULL
      ) AS approved_aid_applications_count,
      (
        SELECT COUNT(aid_applications.id)
        FROM aid_applications
        WHERE
          organization_id = organizations.id
          AND disbursed_at IS NOT NULL
      ) AS disbursed_aid_applications_count,
      (
        SELECT COUNT(aid_applications.id)
        FROM aid_applications
        WHERE
          organization_id = organizations.id 
          AND rejected_at IS NOT NULL
      ) AS rejected_aid_applications_count,
      (
        SELECT COUNT(aid_application_waitlists.aid_application_id)
        FROM aid_application_waitlists
        WHERE
          organization_id = organizations.id
      ) AS waitlisted_aid_applications_count
    SQL
  }

  validates :slug, uniqueness: true, allow_nil: true

  def committed_aid_applications_count
    @total_aid_applications_count ||= attributes["committed_aid_applications_count"] || aid_applications.submitted.count
  end

  [:submitted, :approved, :disbursed, :paused, :rejected, :waitlisted].each do |status|
    class_eval <<~RUBY
      def #{status}_aid_applications_count
        @#{status}_aid_applications_count ||= attributes["#{status}_aid_applications_count"] || aid_applications.only_#{status}.count
      end
    RUBY
  end

  def counts_by_county
    return @_counts_by_county if @_counts_by_county

    raw_counts = {
      total: aid_applications.submitted.group(:county_name).count,
      submitted: aid_applications.only_submitted.group(:county_name).count,
      approved: aid_applications.only_approved.group(:county_name).count,
      disbursed: aid_applications.only_disbursed.group(:county_name).count,
      paused: aid_applications.only_paused.group(:county_name).count,
      rejected: aid_applications.only_rejected.group(:county_name).count,
      waitlisted: aid_applications.only_waitlisted.group(:county_name).count,
    }

    by_counties = {}
    raw_counts.each do |type, counties|
      counties.each do |county, count|
        next if county.nil?
        by_counties[county] ||= {}
        by_counties[county][type] = count
      end
    end

    # Zero out any missing types
    by_counties.each do |_county, counts|
      raw_counts.each do |type, _|
        counts[type] ||= 0
      end
    end

    # Do the Totals row
    by_counties['Total'] = raw_counts.each_with_object({}) do |(type, _), obj|
      obj[type] = by_counties.inject(0) { |memo, (_county, counts)| memo + counts[type] }
    end

    @_counts_by_county = by_counties.sort.to_h
  end

  def low_on_cards?
    total_cards = total_payment_cards_count
    remaining_cards = total_cards - committed_aid_applications_count

    card_limit = case
                 when total_cards > 11_000
                   2000
                 when total_cards > 6000
                   1000
                 else
                   500
                 end

    (remaining_cards < card_limit) && remaining_cards.positive?
  end

  def using_waitlist?
    waitlisted_aid_applications_count > 0
  end

  def no_cards?
    (total_payment_cards_count - disbursed_aid_applications_count) <= 0
  end

  def contact_information_for_county(county)
    if contact_information.include?('/')
      contacts_by_county = contact_information.split('/').each_with_object({}) do |county_info, obj|
        matches = county_info.match(/(.*) County\: (.*)/)
        county_name = matches[1].strip
        phone_number = matches[2].strip

        obj[county_name] = phone_number
      end

      contacts_by_county[county]
    else
      contact_information
    end
  end

  def submission_instructions(application_number:, county:, locale: 'en')
    result = I18n.t("submission_instructions.#{slug}",
                    application_number: application_number,
                    deep_interpolation: true,
                    contact_information: contact_information_for_county(county),
                    locale: locale,
                    default: '')

    if result.is_a?(Hash)
      county_key = county.parameterize(separator: '_').to_sym
      result = result[county_key].presence || result[:default]
    end

    result.presence || I18n.t("submission_instructions.default",
                              application_number: application_number,
                              contact_information: contact_information_for_county(county),
                              locale: locale)
  end
end
