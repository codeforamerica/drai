require 'rails_helper'

RSpec.describe AidApplication, type: :model do
  let(:aid_application) {create :aid_application}

  describe 'factories' do
    specify 'aid_application is submittable but not submitted' do
      aid_application = build :aid_application
      expect(aid_application).to be_valid
      expect(aid_application.eligible?).to eq true
      expect(aid_application).to be_valid(:submit)
      expect(aid_application.submitted?).to eq false
    end

    specify 'new_aid_application is ineligible' do
      aid_application = build :new_aid_application
      expect(aid_application).to be_valid
      expect(aid_application.eligible?).to eq false
      expect(aid_application).not_to be_valid(:eligibility)
    end

    specify 'eligible_aid_application is eligible but not submittable' do
      aid_application = build :eligible_aid_application
      expect(aid_application).to be_valid
      expect(aid_application.eligible?).to eq true
      expect(aid_application).not_to be_valid(:submit)
    end
  end

  describe '#organization' do
    it 'is required' do
      aid_application.organization = nil
      expect(aid_application).not_to be_valid
      expect(aid_application.errors[:organization]).to include("must exist")
    end
  end

  describe '.filter_by_params' do
    let(:assister) {create :assister}
    let!(:disbursed_app) {create :aid_application, :disbursed, creator: assister}
    let!(:approved_app) {create :aid_application, :approved, creator: assister}
    let!(:submitted_app) {create :aid_application, :submitted, creator: assister, phone_number: "1112223333"}

    before do
      AidApplicationSearch.refresh
    end

    it 'handles blank params' do
      expect(described_class.filter_by_params({})).to eq([submitted_app, approved_app, disbursed_app])
    end

    it ' filters by status' do
      expect(described_class.filter_by_params({status: 'approved'})).to eq([approved_app])
    end

    it 'filters by status garbage' do
      expect(described_class.filter_by_params({status: 'garbage'})).to eq([submitted_app, approved_app, disbursed_app])
    end

    it 'orders by status value' do
      expect(described_class.filter_by_params({order: 'asc'})).to eq([disbursed_app, approved_app, submitted_app])
    end

    it 'searches' do
      expect(described_class.filter_by_params({q: approved_app.application_number})).to eq([approved_app])
    end

    it 'searches by phone number' do
      expect(described_class.filter_by_params({q: "(111) 222-3333"})).to eq([submitted_app])
    end

    it 'filters by search and status' do
      expect(described_class.filter_by_params({q: approved_app.application_number, status: 'disbursed'})).to eq([])
    end

    it 'does it all' do
      expect(described_class.filter_by_params({q: 'APP', status: 'disbursed', order: 'desc'})).to eq([disbursed_app])
    end
  end

  describe '#creator' do
    it 'is required' do
      aid_application.creator = nil
      expect(aid_application).not_to be_valid
      expect(aid_application.errors[:creator]).to include("must exist")
    end
  end

  describe '#street_address' do
    it 'is required' do
      aid_application = build :aid_application, street_address: ''
      expect(aid_application).not_to be_valid(:submit)
    end
  end

  describe '#city' do
    it 'is required' do
      aid_application = build :aid_application, city: ''
      expect(aid_application).not_to be_valid(:submit)
    end
  end

  describe '#zip_code' do
    it 'is required' do
      aid_application = build :aid_application, zip_code: ''
      expect(aid_application).not_to be_valid(:submit)
    end

    it 'must be valid' do
      aid_application = build :aid_application, zip_code: 'none'
      expect(aid_application).not_to be_valid(:submit)
    end

    it 'cannot be outside of california' do
      aid_application = build :aid_application, zip_code: '89101'
      expect(aid_application).not_to be_valid(:submit)
    end

    it 'cannot be in a county not supported by the organization' do
      organization = create :organization, county_names: ["San Francisco", "Alameda"]
      aid_application = build :aid_application, organization: organization, zip_code: '94303' # San Mateo and Santa Clara
      expect(aid_application).not_to be_valid(:submit)
      expect(aid_application.errors[:zip_code]).to include "94303 is in San Mateo County, which is outside of your organization's service area. Please update the ZIP code or refer the applicant to the organization that can serve them."
    end

    it 'uses a different error message when the zip code is out of state' do
      organization = create :organization, county_names: ["San Francisco", "Alameda"]
      aid_application = build :aid_application, organization: organization, zip_code: '89101'
      expect(aid_application).not_to be_valid(:submit)
      expect(aid_application.errors[:zip_code]).to include "89101 is in another state, which is outside of your organization's service area. Please update the ZIP code or refer the applicant to the organization that can serve them."
    end

    it 'updates the county to match the zip code if they do not match but the new county is supported by the organization' do
      organization = create :organization, county_names: ["San Francisco", "San Mateo"]
      aid_application = create :aid_application, organization: organization, county_name: 'San Francisco'
      aid_application.update(zip_code: '94303') # San Mateo and Santa Clara

      expect(aid_application).to be_valid(:submit)
      expect(aid_application.reload.county_name).to eq 'San Mateo'
    end
  end

  describe '#mailing_street_address' do
    it 'is required' do
      aid_application = build :aid_application, mailing_street_address: ''
      expect(aid_application).not_to be_valid(:submit)
    end

    it 'is only required when allow_mailing_address is set to true' do
      aid_application = build :aid_application, allow_mailing_address: false, mailing_street_address: ''
      expect(aid_application).to be_valid(:submit)
    end
  end

  describe '#mailing_city' do
    it 'is required' do
      aid_application = build :aid_application, mailing_city: ''
      expect(aid_application).not_to be_valid(:submit)
    end

    it 'is only required when allow_mailing_address is set to true' do
      aid_application = build :aid_application, allow_mailing_address: false, mailing_city: ''
      expect(aid_application).to be_valid(:submit)
    end
  end

  describe '#mailing_state' do
    it 'is required' do
      aid_application = build :aid_application, mailing_state: ''
      expect(aid_application).not_to be_valid(:submit)
    end

    it 'is only required when allow_mailing_address is set to true' do
      aid_application = build :aid_application, allow_mailing_address: false, mailing_state: ''
      expect(aid_application).to be_valid(:submit)
    end
  end

  describe '#mailing_zip_code' do
    it 'must be 5 digits' do
      aid_application = build :aid_application, mailing_zip_code: '1234'
      expect(aid_application).not_to be_valid(:submit)
    end

    it 'can be outside of CA' do
      aid_application = build :aid_application, mailing_zip_code: '12345'
      expect(aid_application).to be_valid(:submit)
    end

    it 'is only required when allow_mailing_address is set to true' do
      aid_application = build :aid_application, allow_mailing_address: false, mailing_zip_code: ''
      expect(aid_application).to be_valid(:submit)
    end
  end

  describe '#phone_number' do
    it 'is required' do
      aid_application = build :aid_application, phone_number: ''
      expect(aid_application).not_to be_valid(:submit)
    end

    it 'must be a valid number' do
      aid_application = build :aid_application, phone_number: '111'
      expect(aid_application).not_to be_valid(:submit)
    end

    it 'allows intermediate characters' do
      aid_application = build :aid_application, phone_number: '+1-555-666.1234'
      expect(aid_application).to be_valid(:submit)
      expect(aid_application.phone_number).to eq '5556661234'
    end
  end

  describe '#email' do
    context 'email_consent is false' do
      it 'is not required' do
        aid_application = build :aid_application, email_consent: false, email: ''
        expect(aid_application).to be_valid(:submit)
      end
    end

    context 'email_consent is true' do
      it 'is required' do
        aid_application = build :aid_application, email_consent: true, email: ''
        expect(aid_application).not_to be_valid(:submit)
      end

      it 'must be valid' do
        aid_application = build :aid_application, email_consent: true, email: '@garbage'
        expect(aid_application).not_to be_valid(:submit)
      end
    end
  end

  describe 'sms_consent or email_consent must be true' do
    context 'neither sms_consent nor email_consent is true' do
      it 'is invalid' do
        aid_application = build :aid_application, sms_consent: false, email_consent: false
        expect(aid_application).not_to be_valid(:submit)
      end
    end

    context 'sms_consent is true' do
      it 'is valid' do
        aid_application = build :aid_application, sms_consent: true, email_consent: false
        expect(aid_application).to be_valid(:submit)
      end
    end

    context 'email_consent is true' do
      it 'is valid' do
        aid_application = build :aid_application, sms_consent: false, email_consent: true, email: 'e@example.com'
        expect(aid_application).to be_valid(:submit)
      end
    end

    describe 'mailgun validation' do
      it 'contains errors if the email changes to something mailgun rejects' do
        allow(MailgunEmailValidator).to receive(:valid?).and_return(false)

        aid_application = build :aid_application, email_consent: true, email: 'e@example.com'
        aid_application.valid?(:submit)
        expect(aid_application.errors[:email]).to be_present

        expect(aid_application.error_message?(:email, :mailgun_email_invalid)).to be true
      end
    end
  end

  describe 'landline' do
    context 'is true' do
      it 'sets sms_consent to false' do
        aid_application = build :aid_application, sms_consent: true, landline: true
        aid_application.save
        expect(aid_application.reload.sms_consent).to eq false
      end
    end
  end

  describe '#receives_calfresh_or_calworks' do
    it 'is required' do
      aid_application = build :aid_application, receives_calfresh_or_calworks: nil
      expect(aid_application).not_to be_valid(:submit)
      expect(aid_application.errors[:receives_calfresh_or_calworks]).to be_present
    end

    it 'allows false' do
      aid_application = build :aid_application, receives_calfresh_or_calworks: false
      expect(aid_application).to be_valid(:submit)
    end
  end

  describe '#racial_ethnic_identity' do
    it 'is required' do
      aid_application = build :aid_application, racial_ethnic_identity: nil
      expect(aid_application).not_to be_valid(:submit)
      expect(aid_application.errors[:racial_ethnic_identity]).to be_present
    end
  end

  describe '#attestation' do
    it 'must be true' do
      aid_application = build :aid_application, attestation: nil
      expect(aid_application).not_to be_valid(:submit)
    end
  end

  describe '#no_cbo_association' do
    it 'must be true' do
      aid_application = build :aid_application, no_cbo_association: nil
      expect(aid_application).not_to be_valid(:eligibility)
    end
  end

  describe '#valid_work_authorization' do
    it 'must be false' do
      aid_application = build :aid_application, valid_work_authorization: true
      expect(aid_application).not_to be_valid(:eligibility)
    end
  end

  describe '#unmet_needs_required' do
    it 'is must have at least one unmet need checked' do
      aid_application = build :aid_application,
                              unmet_childcare: nil,
                              unmet_food: nil,
                              unmet_housing: nil,
                              unmet_other: nil,
                              unmet_transportation: nil,
                              unmet_utilities: nil

      expect(aid_application).not_to be_valid(:submit)
    end
  end

  describe '#eligibility_required' do
    it 'must have at least one covid19 criteria checked' do
      aid_application = build :aid_application,
                              covid19_care_facility_closed: nil,
                              covid19_caregiver: nil,
                              covid19_experiencing_symptoms: nil,
                              covid19_reduced_work_hours: nil,
                              covid19_underlying_health_condition: nil
      expect(aid_application).not_to be_valid(:eligibility)
    end
  end

  describe '#county_name' do
    it "must be one of the organization's county_names" do
      aid_application = build :aid_application, county_name: "None of the above", organization: build(:organization, county_names: ["Alameda"])
      expect(aid_application).not_to be_valid(:eligibility)
    end
  end

  describe '#contact_method_confirmed' do
    it 'must be true' do
      aid_application = build :aid_application, contact_method_confirmed: nil
      expect(aid_application).not_to be_valid(:confirmation)
    end
  end

  describe '#card_receipt_method' do
    it 'is required' do
      aid_application = build :aid_application, card_receipt_method: nil
      expect(aid_application).not_to be_valid(:confirmation)
    end
  end

  describe '.query' do
    let!(:aid_application) { create :aid_application, :submitted, city: 'Riverside' }
    let!(:other_aid_application) { create :aid_application, :submitted, city: 'San Diego' }

    before do
      AidApplicationSearch.refresh
    end

    it 'performs a scoped query against associated AidApplicationSearch' do
      expect(described_class.query('Riverside')).to eq [aid_application]
    end

    it 'can search Aid Applications even if the Index is not refreshed' do
      another_aid_application = create :aid_application, :submitted, city: 'Riverside'
      expect(described_class.query(another_aid_application.application_number)).to eq [another_aid_application]
    end

    it 'allows searching by various formats of Application Number' do
      another_aid_application = create :aid_application, :submitted, application_number: "APP-1-234-567"
      AidApplicationSearch.refresh
      expect(described_class.query("APP 1-234-567")).to eq [another_aid_application]
      expect(described_class.query("1-234-567")).to eq [another_aid_application]
      expect(described_class.query("1234567")).to eq [another_aid_application]
    end

    it 'allow searching by sequence_number' do
      disbursed_aid_application = create :aid_application, :disbursed
      AidApplicationSearch.refresh
      expect(described_class.query(disbursed_aid_application.payment_card.sequence_number)).to eq [disbursed_aid_application]
    end

    it 'allows searching by birthday' do
      birthday_aid_application = create :aid_application, :disbursed, birthday: 'February 14, 1980'
      AidApplicationSearch.refresh
      expect(described_class.query('2/14/1980')).to eq [birthday_aid_application]
    end
  end

  describe '.matching_submitted_apps' do
    let(:name) {"Fake Name"}
    let(:same_name) { " Faké,   Name "}
    let(:birthday) {'January 1, 1980'}
    let(:zip_code) {'12345'}

    context 'there are existing submitted apps with the same name, birthday, zip code and street address' do
      it 'returns the matching apps' do
        street_address = '123 Main St'
        apartment_number = '6'
        aid_application = create :aid_application, :submitted, name: name, birthday: birthday, zip_code: zip_code, street_address: street_address, apartment_number: apartment_number
        duplicate_aid_application = create :aid_application, :submitted, name: same_name, birthday: birthday, zip_code: zip_code, street_address: '123 N Main St', apartment_number: apartment_number
        _unsubmitted_matching_aid_application = create :aid_application, name: name, birthday: birthday, zip_code: zip_code, street_address: street_address, apartment_number: apartment_number
        _submitted_street_address_does_not_match_aid_application = create :aid_application, :submitted, name: name, birthday: birthday, zip_code: zip_code, street_address: '456 Pine 123 St', apartment_number: apartment_number
        _submitted_apartment_does_not_match_aid_application = create :aid_application, :submitted, name: name, birthday: birthday, zip_code: zip_code, street_address: street_address, apartment_number: '14'
        _submitted_name_does_not_match_aid_application = create :aid_application, :submitted, name: 'different name', birthday: birthday, zip_code: zip_code, street_address: street_address, apartment_number: apartment_number
        extra_white_space_in_fields_aid_application = create :aid_application, :submitted, name: "#{name}    ", birthday: birthday, zip_code: "#{zip_code}       ", street_address: " #{street_address}", apartment_number: apartment_number
        different_cases_aid_application = create :aid_application, :submitted, name: name.upcase, birthday: birthday, zip_code: zip_code, street_address: street_address, apartment_number: apartment_number

        expect(AidApplication.matching_submitted_apps(aid_application)).to contain_exactly(duplicate_aid_application, extra_white_space_in_fields_aid_application, different_cases_aid_application)
      end
    end

    context "the application's street address does not start with a number" do
      it 'only matches duplicates by name, birthday, and zip code' do
        aid_application = create :aid_application, :submitted, name: name, birthday: birthday, zip_code: zip_code, street_address: '5th and Howard'
        duplicate_aid_application = create :aid_application, :submitted, name: name, birthday: birthday, zip_code: zip_code, street_address: '123 Main St'

        expect(AidApplication.matching_submitted_apps(aid_application)).to eq [duplicate_aid_application]
      end
    end
  end

  describe '.matching_approved_apps' do
    context 'there are existing approved apps with the same name, birthday, zip code and street address' do
      it 'returns the matching apps' do
        name = "Fake Name"
        birthday = 'January 1, 1980'
        zip_code = '12345'
        street_address = '123 Main St'
        apartment_number = '#1'
        aid_application = create :aid_application, :submitted, name: name, birthday: birthday, zip_code: zip_code, street_address: street_address, apartment_number: apartment_number
        duplicate_aid_application = create :aid_application, :approved, name: name, birthday: birthday, zip_code: zip_code, street_address: street_address, apartment_number: apartment_number
        _unapproved_matching_aid_application = create :aid_application, :submitted, name: name, birthday: birthday, zip_code: zip_code, street_address: street_address
        _approved_street_address_does_not_match_aid_application = create :aid_application, :approved, name: name, birthday: birthday, zip_code: zip_code, street_address: 'other street address'
        _approved_name_does_not_match_aid_application = create :aid_application, :approved, name: 'different name', birthday: birthday, zip_code: zip_code, street_address: street_address
        extra_white_space_in_fields_aid_application = create :aid_application, :approved, name: "#{name}    ", birthday: birthday, zip_code: "#{zip_code}       ", street_address: " #{street_address}", apartment_number: apartment_number

        expect(AidApplication.matching_approved_apps(aid_application)).to contain_exactly(duplicate_aid_application, extra_white_space_in_fields_aid_application)
      end
    end
  end

  describe '.delete_stale_and_unsubmitted' do
    it 'deletes unsubmitted aid applications that are more than 24 hours old' do
      submitted_application = create :aid_application, :submitted
      approved_application = create :aid_application, :approved
      disbursed_application = create :aid_application, :disbursed
      recent_application = create :aid_application, created_at: 1.hour.ago
      _old_unsubmitted_application = create :aid_application, created_at: 25.hour.ago
      described_class.delete_stale_and_unsubmitted

      expect(AidApplication.all).to contain_exactly(submitted_application, approved_application, disbursed_application, recent_application)
    end
  end

  describe '.pause_stale_and_unapproved' do
    it 'pauses unapproved aid applications that are more than 12 days old' do
      submitted_application = create :aid_application, :submitted, submitted_at: 11.days.ago
      approved_application = create :aid_application, :approved
      disbursed_application = create :aid_application, :disbursed
      old_unapproved_application = create :aid_application, :submitted, submitted_at: 13.days.ago
      unpaused_application = create :aid_application, :unpaused, submitted_at: 14.days.ago, unpaused_at: 1.days.ago
      repaused_application = create :aid_application, :submitted, submitted_at: 26.days.ago, unpaused_at: 13.days.ago

      described_class.pause_stale_and_unapproved

      expect(AidApplication.paused).to contain_exactly(old_unapproved_application, repaused_application)
      expect(AidApplication.submitted).to contain_exactly(submitted_application, approved_application, disbursed_application, unpaused_application)
    end
  end

  describe '#disburse' do
    let(:supervisor) {create :supervisor}
    let(:payment_card) {create :payment_card}
    let(:aid_application) {create :aid_application}

    it 'attaches itself the the aid application and generates an activation code' do
      aid_application.disburse(payment_card, disburser: supervisor)

      expect(payment_card.aid_application).to eq aid_application
      expect(payment_card.activation_code).to be_present
      expect(payment_card.activation_code.size).to eq 6
      expect(aid_application.payment_card).to eq payment_card
      expect(aid_application.disbursed_at).to be_within(1.second).of Time.current
      expect(aid_application.disburser).to eq supervisor
    end
  end

  describe '#save_and_submit' do
    let(:aid_application) {create :aid_application}

    it 'adds a submitted_at and submitter' do
      expect {
        aid_application.save_and_submit(submitter: aid_application.creator)
      }.to change {aid_application.reload.submitted_at}.from(nil).to within(1.second).of Time.current
      expect(aid_application.reload.submitter).to eq aid_application.creator
    end

    it 'generates a application_number' do
      expect {
        aid_application.save_and_submit(submitter: aid_application.creator)
      }.to change {aid_application.reload.application_number.present?}.from(false).to true
    end
  end

  describe '#save_and_approve' do
    let(:aid_application) {create :aid_application}

    it 'adds an approved_at' do
      expect {
        aid_application.save_and_approve(approver: aid_application.creator)
      }.to change {aid_application.reload.approved_at}.from(nil).to(within(1.second).of Time.current)
      expect(aid_application.reload.approver).to eq aid_application.creator

    end
  end

  describe '#application_number' do
    it 'cannot be changed once assigned' do
      aid_application = create :aid_application, :submitted
      expect do
        aid_application.update application_number: 'something else'
      end.not_to change {aid_application.reload.application_number}
    end
  end

  describe '#generate_unique_identifer' do
    let(:aid_application) {create :aid_application}

    it 'is in the shape of APP-[organization_id]-123-456' do
      expect(aid_application.generate_application_number).to match /APP-#{aid_application.organization.id}-\d{3}-\d{3}/
    end

    it 'cycles through values until it finds a valid one' do
      tried_values = []
      allow(described_class).to receive :exists? do |**args|
        tried_values << args[:application_number]
        tried_values.size < 4 ? true : false
      end

      aid_application.generate_application_number

      expect(tried_values.uniq.size).to eq 4
    end
  end

  describe '#send_submission_notification' do
    context 'when SMS consent' do
      let(:preferred_language) {'English'}
      let(:aid_application) {create :aid_application, :submitted, email: '', preferred_language: preferred_language}

      it 'sends an SMS welcome message and then SMS application number message' do
        perform_enqueued_jobs do
          aid_application.send_submission_notification
        end

        sms_messages = ActionMailer::Base.deliveries.select { |m| m.to.include? PhoneNumberFormatter.format(aid_application.phone_number) }
        first_message = sms_messages.first
        second_message = sms_messages.second

        expect(first_message).to be_present
        expect(first_message.body).to eq I18n.t('text_message.subscribed', contact_information: aid_application.organization.contact_information, locale: 'en')

        expect(second_message).to be_present
        expect(second_message.body).to eq I18n.t('submission_instructions.default', application_number: aid_application.application_number, contact_information: aid_application.organization.contact_information, locale: 'en')
      end

      it 'records a Message object' do
        perform_enqueued_jobs do
          aid_application.send_submission_notification
        end

        expect(aid_application.message_logs.size).to eq 2
      end

      context 'when the application has a preferred_language of Spanish' do
        let(:preferred_language) { 'Spanish' }

        it 'sends the SMS messages in Spanish' do
          perform_enqueued_jobs do
            aid_application.send_submission_notification
          end

          sms_messages = ActionMailer::Base.deliveries.select { |m| m.to.include? PhoneNumberFormatter.format(aid_application.phone_number) }
          expect(sms_messages.second.body.to_s).to include("solicitud para asistencia")
        end
      end

      context 'when app is submitted by CHIRLA' do
        let!(:organization) {create :organization, name: "Coalition for Humane Immigrant Rights", slug: 'chirla' }
        let!(:assister) {create :assister, organization: organization}
        let(:aid_application) {create :aid_application, :submitted, email_consent: false, creator: assister}

        it 'sends the CHIR-specific SMS message' do
          perform_enqueued_jobs do
            aid_application.send_submission_notification
          end

          sms_messages = ActionMailer::Base.deliveries.select { |m| m.to.include? PhoneNumberFormatter.format(aid_application.phone_number) }
          second_message = sms_messages.second

          expect(second_message.body).to eq I18n.t('submission_instructions.chirla', application_number: aid_application.application_number, locale: 'en')
        end
      end

      context 'when app is submitted by a multi-county organization' do
        let!(:organization) {create :organization, county_names: ['San Francisco', 'Alameda'], contact_information: "San Francisco County: 555-555-5555 / Alameda County: 444-444-4444" }
        let!(:assister) {create :assister, organization: organization}
        let(:aid_application) {create :aid_application, :submitted, email_consent: false, creator: assister, county_name: 'San Francisco' }

        it 'sends submission message with county-specific phone number' do
          perform_enqueued_jobs do
            aid_application.send_submission_notification
          end

          sms_messages = ActionMailer::Base.deliveries.select { |m| m.to.include? PhoneNumberFormatter.format(aid_application.phone_number) }
          second_message = sms_messages.second

          expect(second_message.body).to eq I18n.t('submission_instructions.default', application_number: aid_application.application_number, contact_information: '555-555-5555', locale: 'en')
        end
      end
    end

    context 'when email consent' do
      let(:preferred_language) {'English'}
      let(:aid_application) {create :aid_application, :submitted, sms_consent: false, preferred_language: preferred_language}

      it 'sends an email with the application number message' do
        perform_enqueued_jobs do
          aid_application.send_submission_notification
        end

        email_message = ActionMailer::Base.deliveries.find { |m| m.to.include? aid_application.email }
        expect(email_message).to be_present

        expect(email_message.subject).to eq I18n.t('email_message.application_number.subject', application_number: aid_application.application_number, locale: 'en')
        expect(email_message.html_part.body.to_s).to eq I18n.t('submission_instructions.default', application_number: aid_application.application_number, contact_information: aid_application.organization.contact_information, locale: 'en')
      end

      it 'records a Message object' do
        perform_enqueued_jobs do
          aid_application.send_submission_notification
        end

        expect(aid_application.message_logs.size).to eq 1
      end

      context 'when the application has a preferred_language of Spanish' do
        let(:preferred_language) {'Spanish'}

        it 'sends the email messages in Spanish' do
          perform_enqueued_jobs do
            aid_application.send_submission_notification
          end

          email_message = ActionMailer::Base.deliveries.find { |m| m.to.include? aid_application.email }
          expect(email_message).to be_present

          expect(email_message.subject).to eq I18n.t('email_message.application_number.subject', application_number: aid_application.application_number, locale: 'es')
          expect(email_message.html_part.body.to_s).to include "solicitud para asistencia"
        end
      end

      context 'when an app is submitted by CHIR' do
        let!(:organization) {create :organization, name: "Coalition for Humane Immigrant Rights", slug: 'chirla'}
        let!(:assister) {create :assister, organization: organization}
        let(:aid_application) {create :aid_application, :submitted, email_consent: true, sms_consent: false, creator: assister}

        it 'send CHIR-specific email message' do
          perform_enqueued_jobs do
            aid_application.send_submission_notification
          end

          email_message = ActionMailer::Base.deliveries.find { |m| m.to.include? aid_application.email }
          expect(email_message.html_part.body.to_s).to eq I18n.t('submission_instructions.chirla', application_number: aid_application.application_number, locale: 'en')
        end
      end
    end
  end

  describe '#send_disbursement_notification' do
    context 'when SMS consent' do
      let(:preferred_language) {'English'}
      let(:aid_application) {create :aid_application, :disbursed, email_consent: false, preferred_language: preferred_language}

      it 'sends an SMS' do
        perform_enqueued_jobs do
          aid_application.send_disbursement_notification
        end

        sms_message = ActionMailer::Base.deliveries.find { |m| m.to.include? PhoneNumberFormatter.format(aid_application.phone_number) }
        expect(sms_message.body).to eq I18n.t(
          'text_message.activation',
          activation_code: aid_application.payment_card.activation_code,
          ivr_phone_number: BlackhawkApi.ivr_phone_number,
          locale: 'en'
        )
      end

      it 'records a Messages objects' do
        perform_enqueued_jobs do
          aid_application.send_disbursement_notification
        end

        expect(aid_application.message_logs.size).to eq 2
      end

      context 'with preferred language set to Spanish' do
        let(:preferred_language) {'Spanish'}

        it 'sends an SMS in the preferred language' do
          expect do
            aid_application.send_disbursement_notification
          end.to have_enqueued_job(ActionMailer::MailDeliveryJob)
                     .with("ApplicationTexter", "basic_message", "deliver_now",
                           params: {messageable: aid_application},
                           args: [{
                                      to: aid_application.phone_number,
                                      body: I18n.t(
                                          'text_message.activation',
                                          activation_code: aid_application.payment_card.activation_code,
                                          ivr_phone_number: BlackhawkApi.ivr_phone_number,
                                          locale: 'es'
                                      )
                                  }]
                     )
        end
      end
    end

    context 'when email consent' do
      let(:aid_application) {create :aid_application, :disbursed, sms_consent: false}

      it 'sends an email' do
        expect do
          aid_application.send_disbursement_notification
        end.to have_enqueued_job(ActionMailer::MailDeliveryJob).with("ApplicationEmailer", any_args)
      end

      it 'records a Message object' do
        perform_enqueued_jobs do
          aid_application.send_disbursement_notification
        end

        expect(aid_application.message_logs.size).to eq 1
        message_log = aid_application.message_logs.first
        expect(message_log).to have_attributes(
                                 messageable: aid_application,
                                 subject: "Disaster Assistance payment card activation code",
                                 body: a_string_including(aid_application.payment_card.activation_code)
                               )
      end
    end

    context 'when both consents' do
      let(:aid_application) {create :aid_application, :disbursed}

      it 'sends both email and sms' do
        expect do
          aid_application.send_disbursement_notification
        end.to have_enqueued_job(ActionMailer::MailDeliveryJob).with("ApplicationEmailer", any_args)
                   .and have_enqueued_job(ActionMailer::MailDeliveryJob).with("ApplicationTexter", any_args)
      end

    end
  end

  describe '#locale' do
    it 'returns English key' do
      aid_application.preferred_language = 'English'
      expect(aid_application.locale).to eq 'en'
    end

    it 'returns Spanish for indigenous languages' do
      [
        'Spanish',
        'Kanjobal',
        'Mam',
        'Mixteco',
        'Triqui',
        'Zapoteco'
      ].each do |language|
        aid_application.preferred_language = language
        expect(aid_application.locale).to eq('es'), "#{language} should return 'es'"
      end
    end
  end
  describe 'papertrail' do
    it 'tracks changes' do
      expect do
        aid_application.update name: "something else"
      end.to change {aid_application.reload.versions.count}.by(1)
    end
  end
end
