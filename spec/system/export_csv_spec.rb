require 'rails_helper'
require 'csv'

describe 'Export CSV', type: :system do
  let(:supervisor) { create :supervisor }
  let!(:unsubmitted_aid_applications) { create_list :aid_application, 2, organization: supervisor.organization }
  let!(:submitted_aid_applications) { create_list :aid_application, 2, :submitted, organization: supervisor.organization }
  let!(:approved_aid_applications) { create_list :aid_application, 2, :approved, organization: supervisor.organization }
  let!(:disbursed_aid_applications) { create_list :aid_application, 2, :disbursed, organization: supervisor.organization }
  let!(:other_aid_applications) { create_list :aid_application, 2, :submitted }

  specify do
    sign_in supervisor

    visit root_path

    click_on 'Download data'

    click_on 'Download CSV'

    raw_csv = page.body
    csv = CSV.parse(raw_csv, headers: true)

    expect(csv.size).to eq(6)
    expect(csv.map { |r| r['application_number'] }).not_to include(*other_aid_applications.map(&:application_number))

    disbursed_app = disbursed_aid_applications.first
    disbursed_row = csv.find { |r| r['application_number'] == disbursed_app.application_number }

    expect(disbursed_row.to_h).to eq({
                                       'application_number' => disbursed_app.application_number,
                                       'status' => 'disbursed',
                                       'name' => disbursed_app.name,
                                       'county_name' => disbursed_app.county_name,
                                       "phone_number" => disbursed_app.phone_number,
                                       "email" => disbursed_app.email,
                                       "street_address" => disbursed_app.street_address,
                                       "apartment_number" => disbursed_app.apartment_number,
                                       "city" => disbursed_app.city,
                                       "zip_code" => disbursed_app.zip_code,
                                       "mailing_street_address" => disbursed_app.mailing_street_address,
                                       "mailing_apartment_number" => disbursed_app.mailing_apartment_number,
                                       "mailing_city" => disbursed_app.mailing_city,
                                       "mailing_state" => disbursed_app.mailing_state,
                                       "mailing_zip_code" => disbursed_app.mailing_zip_code,
                                       'payment_card_sequence_number' => disbursed_app.payment_card.sequence_number,
                                       'preferred_card_receipt_method' => disbursed_app.card_receipt_method,
                                       'submitter' => disbursed_app.submitter.name,
                                       'approver' => disbursed_app.approver.name,
                                       'disburser' => disbursed_app.disburser.name,
                                       'submitted_at' => disbursed_app.submitted_at.strftime('%Y-%m-%d %H:%M:%S'),
                                       'approved_at' => disbursed_app.approved_at.strftime('%Y-%m-%d %H:%M:%S'),
                                       'disbursed_at' => disbursed_app.disbursed_at.strftime('%Y-%m-%d %H:%M:%S'),
                                     })

    export_log = ExportLog.last
    expect(export_log.created_at).to be_within(1.second).of Time.current
    expect(export_log.exporter).to eq supervisor
  end
end
