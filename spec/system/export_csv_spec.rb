require 'rails_helper'
require 'csv'

describe 'Export CSV', type: :system do
  let(:organization) { create :organization, total_payment_cards_count: 4 }
  let(:supervisor) { create :supervisor, organization: organization }
  let!(:unsubmitted_aid_applications) { create_list :aid_application, 2, organization: supervisor.organization }
  let!(:submitted_aid_applications) { create_list :aid_application, 2, :submitted, organization: supervisor.organization }
  let!(:approved_aid_applications) { create_list :aid_application, 2, :approved, organization: supervisor.organization }
  let!(:disbursed_aid_applications) { create_list :aid_application, 2, :disbursed, organization: supervisor.organization }
  let!(:rejected_aid_applications) { create_list :aid_application, 2, :rejected, organization: supervisor.organization }
  let!(:paused_aid_applications) { create_list :aid_application, 2, :paused, organization: supervisor.organization }
  let!(:unpaused_aid_applications) { create_list :aid_application, 2, :unpaused, organization: supervisor.organization }
  let!(:other_aid_applications) { create_list :aid_application, 2, :submitted }

  before do
    AidApplicationWaitlist.refresh
  end

  specify do
    sign_in supervisor

    visit root_path

    click_on 'Download data'

    click_on 'Download CSV'

    raw_csv = page.body
    csv = CSV.parse(raw_csv, headers: true)

    expect(csv.size).to eq(12)
    expect(csv.map { |r| r['application_number'] }).not_to include(*other_aid_applications.map(&:application_number))

    counts_by_status = csv.group_by { |r| r['status'] }.map { |status, rows| [status, rows.size] }.to_h
    expect(counts_by_status).to eq({
                                    'waitlisted' => 2,
                                    'submitted' => 2,
                                    'approved' => 2,
                                    'disbursed' => 2,
                                    'paused' => 2,
                                    'rejected' => 2,
                                  })

    disbursed_app = disbursed_aid_applications.first
    disbursed_row = csv.find { |r| r['application_number'] == disbursed_app.application_number }

    expect(disbursed_row.to_h).to eq({
                                       'application_number' => disbursed_app.application_number,
                                       'status' => 'disbursed',
                                       'name' => disbursed_app.name,
                                       'birthday' => disbursed_app.birthday.strftime('%Y-%m-%d'),
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
                                       'card_receipt_method' => disbursed_app.card_receipt_method,
                                       'waitlist_position' => "1",
                                       'submitter' => disbursed_app.submitter.name,
                                       'approver' => disbursed_app.approver.name,
                                       'disburser' => disbursed_app.disburser.name,
                                       'rejecter' => disbursed_app.rejecter.try(:name),
                                       'submitted_at' => disbursed_app.submitted_at.strftime('%Y-%m-%d %H:%M:%S'),
                                       'approved_at' => disbursed_app.approved_at.strftime('%Y-%m-%d %H:%M:%S'),
                                       'disbursed_at' => disbursed_app.disbursed_at.strftime('%Y-%m-%d %H:%M:%S'),
                                       'rejected_at' => disbursed_app.rejected_at.try(:strftime, '%Y-%m-%d %H:%M:%S'),
                                       'valid_work_authorization' => boolean_to_string(disbursed_app.valid_work_authorization),
                                       'no_cbo_association' => boolean_to_string(disbursed_app.no_cbo_association),
                                       'attestation' => boolean_to_string(disbursed_app.attestation),
                                       'covid19_reduced_work_hours' => boolean_to_string(disbursed_app.covid19_reduced_work_hours),
                                       'covid19_care_facility_closed' => boolean_to_string(disbursed_app.covid19_care_facility_closed),
                                       'covid19_experiencing_symptoms' => boolean_to_string(disbursed_app.covid19_experiencing_symptoms),
                                       'covid19_underlying_health_condition' => boolean_to_string(disbursed_app.covid19_underlying_health_condition),
                                       'covid19_caregiver' => boolean_to_string(disbursed_app.covid19_caregiver),
                                       'preferred_language' => disbursed_app.preferred_language,
                                       'country_of_origin' => disbursed_app.country_of_origin,
                                       'gender' => disbursed_app.gender,
                                       'sexual_orientation' => disbursed_app.sexual_orientation,
                                       'racial_ethnic_identity' => array_to_string(disbursed_app.racial_ethnic_identity),
                                       'unmet_food' => boolean_to_string(disbursed_app.unmet_food),
                                       'unmet_housing' => boolean_to_string(disbursed_app.unmet_housing),
                                       'unmet_childcare' => boolean_to_string(disbursed_app.unmet_childcare),
                                       'unmet_utilities' => boolean_to_string(disbursed_app.unmet_utilities),
                                       'unmet_transportation' => boolean_to_string(disbursed_app.unmet_transportation),
                                       'unmet_other' => boolean_to_string(disbursed_app.unmet_other),
                                       'receives_calfresh_or_calworks' => boolean_to_string(disbursed_app.receives_calfresh_or_calworks),
                                       'no_cbo_association' => boolean_to_string(disbursed_app.no_cbo_association),
                                       'card_receipt_method' => disbursed_app.card_receipt_method,
                                     })

    export_log = ExportLog.last
    expect(export_log.created_at).to be_within(1.second).of Time.current
    expect(export_log.exporter).to eq supervisor
  end

  def boolean_to_string(boolean)
    return '' if boolean.nil?
    boolean ? 'true' : 'false'
  end

  def array_to_string(array)
    array.join(', ')
  end
end
