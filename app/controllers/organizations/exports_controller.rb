class Organizations::ExportsController < ApplicationController
  before_action :authenticate_supervisor!

  def show
    @export_logs = ExportLog.includes(:exporter).where(organization: current_organization).order(created_at: :desc)
  end

  def create
    ExportLog.create! organization: current_organization, exporter: current_user

    query = current_organization.aid_applications.submitted.left_joins(:payment_card).select(
      :application_number,
      <<~SQL,
        (
          CASE
          WHEN disbursed_at IS NOT NULL THEN 'disbursed'
          WHEN approved_at IS NOT NULL THEN 'approved'
          ELSE 'submitted'
          END
        ) AS status
      SQL
      :name,
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
      "payment_cards.sequence_number AS payment_card_sequence_number",
      "date_trunc('second', submitted_at) AT TIME ZONE 'UTC' AT TIME ZONE 'America/Los_angeles' AS submitted_at",
      "date_trunc('second', approved_at) AT TIME ZONE 'UTC' AT TIME ZONE 'America/Los_angeles' AS approved_at",
      "date_trunc('second', disbursed_at) AT TIME ZONE 'UTC' AT TIME ZONE 'America/Los_angeles' AS disbursed_at",
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

  private

  def csv_filename
    "drai_applications_#{current_organization.name.truncate(20, separator: /\s/).parameterize}.csv"
  end
end