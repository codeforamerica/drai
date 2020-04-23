require 'rails_helper'

describe AidApplications::EditsController do
  describe '#update' do
    let(:assister) { create :assister }
    let(:aid_application) { AidApplication.create!(assister: assister, organization: assister.organization) }

    before { sign_in aid_application.assister }

    it 'creates a new aid application' do
      aid_application_attributes = attributes_for(:aid_application, organization: nil, assister: nil)
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
                                   assister: assister,
                                   organization: assister.organization
                                 )
      expect(aid_application.members.first).to have_attributes(
                                                 name: members_attributes[0][:name]
                                               )
      expect(aid_application.members.second).to have_attributes(
                                                  name: members_attributes[1][:name]
                                                )
    end
  end
end
