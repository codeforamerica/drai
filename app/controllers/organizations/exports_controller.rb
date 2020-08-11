class Organizations::ExportsController < ApplicationController
  before_action :authenticate_supervisor!

  def show
    @export_logs = ExportLog.includes(:exporter).where(organization: current_organization).order(created_at: :desc)
  end

  def create
    ExportLog.create! organization: current_organization, exporter: current_user

    query = current_organization.aid_applications.visible
              .joins("left join users submitters ON submitters.id = submitter_id")
              .joins("left join users approvers ON approvers.id = approver_id")
              .joins("left join users disbursers ON disbursers.id = disburser_id")
              .joins("left join users rejecters ON rejecters.id = rejecter_id")
              .joins("left join aid_application_waitlists ON aid_application_waitlists.aid_application_id = aid_applications.id")
              .left_joins(:payment_card)
              .select(
                  :application_number,
                  <<~SQL,
                    (
                      CASE
                      WHEN disbursed_at IS NOT NULL THEN 'disbursed'
                      WHEN rejected_at IS NOT NULL THEN 'rejected'
                      WHEN approved_at IS NOT NULL THEN 'approved'
                      WHEN paused_at IS NOT NULL THEN 'paused'
                      WHEN waitlist_position IS NOT NULL then 'waitlisted'
                      ELSE 'submitted'
                      END
                    ) AS status
                  SQL
                  :name,
                  "to_char(birthday, 'YYYY-MM-DD') AS birthday",
                  :county_name,
                  :phone_number,
                  :email,
                  :street_address,
                  :apartment_number,
                  :city,
                  :zip_code,
                  :mailing_street_address,
                  :mailing_apartment_number,
                  :mailing_city,
                  :mailing_state,
                  :mailing_zip_code,
                  normalize_boolean_with_sql(:attestation),
                  normalize_boolean_with_sql(:valid_work_authorization),
                  normalize_boolean_with_sql(:covid19_care_facility_closed),
                  normalize_boolean_with_sql(:covid19_reduced_work_hours),
                  normalize_boolean_with_sql(:covid19_experiencing_symptoms),
                  normalize_boolean_with_sql(:covid19_underlying_health_condition),
                  normalize_boolean_with_sql(:covid19_caregiver),
                  normalize_boolean_with_sql(:unmet_food),
                  normalize_boolean_with_sql(:unmet_housing),
                  normalize_boolean_with_sql(:unmet_childcare),
                  normalize_boolean_with_sql(:unmet_utilities),
                  normalize_boolean_with_sql(:unmet_transportation),
                  normalize_boolean_with_sql(:unmet_other),
                  normalize_boolean_with_sql(:receives_calfresh_or_calworks),
                  :preferred_language,
                  :country_of_origin,
                  :sexual_orientation,
                  :gender,
                  normalize_boolean_with_sql(:no_cbo_association),
                  "payment_cards.sequence_number AS payment_card_sequence_number",
                  :card_receipt_method,
                  :waitlist_position,
                  "submitters.name AS submitter",
                  "approvers.name AS approver",
                  "disbursers.name AS disburser",
                  "rejecters.name AS rejecter",
                  "date_trunc('second', submitted_at) AT TIME ZONE 'UTC' AT TIME ZONE 'America/Los_angeles' AS submitted_at",
                  "date_trunc('second', approved_at) AT TIME ZONE 'UTC' AT TIME ZONE 'America/Los_angeles' AS approved_at",
                  "date_trunc('second', disbursed_at) AT TIME ZONE 'UTC' AT TIME ZONE 'America/Los_angeles' AS disbursed_at",
                  "date_trunc('second', rejected_at) AT TIME ZONE 'UTC' AT TIME ZONE 'America/Los_angeles' AS rejected_at",
                  normalize_array_with_sql(:racial_ethnic_identity),
                )
    stream_csv_report(query)
  end

  private

  # https://medium.com/table-xi/stream-csv-files-in-rails-because-you-can-46c212159ab7
  def stream_csv_report(query)
    headers.delete("Content-Length")
    headers["Cache-Control"] = "no-cache"
    headers["X-Accel-Buffering"] = "no"

    headers["Content-Type"] = "text/csv"
    headers["Content-Disposition"] = "attachment; filename=\"#{csv_filename}\""
    headers["Last-Modified"] = Time.current.ctime.to_s

    self.response_body = Enumerator.new do |response_output|
      AidApplication.stream_rows(query.to_sql, "WITH CSV HEADER") do |row_from_db|
        response_output << row_from_db
      end
    end

    response.status = 200
  end

  def csv_filename
    "drai_applications_#{current_organization.name.truncate(20, separator: /\s/).parameterize}.csv"
  end

  def normalize_boolean_with_sql(attribute)
    <<~SQL
      (
        CASE
        WHEN #{attribute} IS TRUE THEN 'true'
        WHEN #{attribute} IS FALSE THEN 'false'
        ELSE ''
        END
      ) AS #{attribute}
    SQL
  end

  def normalize_array_with_sql(attribute)
    <<~SQL
      array_to_string(#{attribute}, ', ', '') AS #{attribute}
    SQL
  end
end
