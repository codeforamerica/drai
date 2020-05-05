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
  end

  describe '#update' do
    let(:assister) { create :assister }
    let(:aid_application) { AidApplication.create!(creator: assister, organization: assister.organization) }

    before { sign_in aid_application.creator }

    it 'updates the aid application' do
      aid_application_attributes = attributes_for(:aid_application, organization: nil, creator: nil)
      members_attributes = attributes_for_list(:member, 2)

      put :update, params: {
        aid_application_id: aid_application.id,
        organization_id: assister.organization.id,
        aid_application: aid_application_attributes.merge(
          members_attributes: {
            '0' => members_attributes[0],
            '1' => members_attributes[1],
          }
        )
      }

      aid_application = assigns(:aid_application)
      expect(aid_application).to be_persisted
      expect(aid_application).to have_attributes(
                                   creator: assister,
                                   organization: assister.organization
                                 )
      expect(aid_application.members.first).to have_attributes(
                                                 name: members_attributes[0][:name]
                                               )
      expect(aid_application.members.second).to have_attributes(
                                                  name: members_attributes[1][:name]
                                                )
    end

    context 'when submit form action' do
      it 'submits the application' do
        aid_application_attributes = attributes_for(:aid_application, organization: nil, creator: nil)
        members_attributes = attributes_for_list(:member, 2)

        expect do
          put :update, params: {
            aid_application_id: aid_application.id,
            organization_id: assister.organization.id,
            aid_application: aid_application_attributes.merge(
              members_attributes: {
                '0' => members_attributes[0],
                '1' => members_attributes[1],
              }
            ),
            form_action: 'submit'
          }
        end.to change { aid_application.reload.submitted_at }.from(nil).to(within(1.second).of(Time.current))
           .and change { aid_application.reload.submitter }.from(nil).to(assister)
           .and change { aid_application.reload.application_number }.from(nil).to(anything)
      end
    end
  end
end
