require 'rails_helper'

describe AidApplications::EditsController do
  let(:assister) { create :assister }
  let(:aid_application) { AidApplication.create!(creator: assister, organization: assister.organization) }

  describe '#edit' do
    context 'when not authenticated' do
      it 'does not allow access' do
        get :edit, params: {
          aid_application_id: aid_application.id,
          organization_id: assister.organization.id,
        }
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'authenticated' do
      context 'when the demographic fields are nil' do
        before { sign_in assister }

        it 'defaults to Decline to state' do
          get :edit, params: {
              aid_application_id: aid_application.id,
              organization_id: assister.organization.id
          }

          aid_application = assigns(:aid_application)
          expect(aid_application.country_of_origin).to eq 'Decline to state'
          expect(aid_application.sexual_orientation).to eq 'Decline to state'
          expect(aid_application.gender).to eq 'Decline to state'
        end
      end

      context 'when the demographic fields have values' do
        before do
          sign_in assister

          aid_application.update(
            country_of_origin: 'Pakistan',
            sexual_orientation: 'Another sexual orientation',
            gender: 'Transgender: Female to Male'
          )
        end

        it 'uses the existing values' do
          get :edit, params: {
              aid_application_id: aid_application.id,
              organization_id: assister.organization.id
          }

          aid_application = assigns(:aid_application)
          expect(aid_application.country_of_origin).to eq 'Pakistan'
          expect(aid_application.sexual_orientation).to eq 'Another sexual orientation'
          expect(aid_application.gender).to eq 'Transgender: Female to Male'
        end
      end
    end
  end

  describe '#update' do
    let(:assister) { create :assister }
    let(:aid_application) { AidApplication.create!(creator: assister, organization: assister.organization) }

    before { sign_in aid_application.creator }

    it 'updates the aid application' do
      aid_application_attributes = attributes_for(:aid_application, organization: nil, creator: nil)

      put :update, params: {
        aid_application_id: aid_application.id,
        organization_id: assister.organization.id,
        aid_application: aid_application_attributes
      }

      aid_application = assigns(:aid_application)
      expect(aid_application).to be_persisted
      expect(aid_application).to have_attributes(
                                   creator: assister,
                                   organization: assister.organization
                                 )
    end

    context 'when submit form action' do
      it 'submits the application' do
        aid_application_attributes = attributes_for(:aid_application, organization: nil, creator: nil)

        expect do
          put :update, params: {
            aid_application_id: aid_application.id,
            organization_id: assister.organization.id,
            aid_application: aid_application_attributes,
            form_action: 'submit'
          }
        end.to change { aid_application.reload.submitted_at }.from(nil).to(within(1.second).of(Time.current))
           .and change { aid_application.reload.submitter }.from(nil).to(assister)
           .and change { aid_application.reload.application_number }.from(nil).to(anything)
      end
    end
  end
end
