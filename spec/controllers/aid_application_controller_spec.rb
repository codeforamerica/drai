require 'rails_helper'

describe AidApplicationsController, type: :controller do
  let(:user) { create :user }

  before { sign_in user }

  describe '#index' do
    it 'returns a 200 status' do
      get :index
      expect(response).to have_http_status :ok
    end
  end

  describe '#new' do
    it 'returns a 200 status' do
      get :new, params: { organization_id: user.organization.id }
      expect(response).to have_http_status :ok
    end
  end

  describe '#create' do
    let(:user_params) { attributes_for :new_user }

    it 'creates a new aid application' do
      post :create, params: { organization_id: user.organization.id }

      aid_application = assigns(:aid_application)
      expect(aid_application).to be_persisted
      expect(aid_application).to have_attributes(
                                   assister: user,
                                   organization: user.organization
                                 )
    end
  end
end
