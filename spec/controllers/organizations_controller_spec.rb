require 'rails_helper'

describe OrganizationsController do
  let(:user) { create :user }

  before { sign_in user }

  describe '#index' do
    it 'returns a 200 status' do
      get :index
      expect(response).to have_http_status :ok
    end
  end

  describe '#show' do
    it 'returns a 200 status' do
      get :show, params: { id: user.organization.id }
      expect(response).to have_http_status :ok
    end
  end
end
