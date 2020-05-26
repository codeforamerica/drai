require 'rails_helper'

describe AidApplications::FinishedsController do
  let(:supervisor) { create :supervisor }
  let!(:aid_application) { create :aid_application, :disbursed, organization: supervisor.organization }

  before do
    sign_in supervisor
  end

  context 'when Re-send Activation Code button is clicked' do
    let!(:aid_application) { create :aid_application, :disbursed, organization: supervisor.organization,  email_consent: false }

    it 'sends resends the activation code' do
      expect do
        put :update, params: {
            organization_id: aid_application.organization_id,
            aid_application_id: aid_application.id,
            form_action: "resend_code"
        }
      end.to have_enqueued_job(ActionMailer::MailDeliveryJob).with("ApplicationTexter", "basic_message", "deliver_now",
                                                                   params: { messageable: aid_application },
                                                                   args: [{
                                                                              to: aid_application.phone_number,
                                                                              body: I18n.t(
                                                                                  'text_message.activation',
                                                                                  activation_code: aid_application.payment_card.activation_code,
                                                                                  ivr_phone_number: BlackhawkApi.ivr_phone_number,
                                                                                  locale: "en"
                                                                              )
                                                                          }]
      )
    end
  end
end
