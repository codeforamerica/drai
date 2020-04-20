require 'rails_helper'

describe AssistersController, type: :controller do
  let(:admin) { create :admin }
  let!(:assister1) { create :assister }
  let!(:assister2) { create :assister }

  describe '#index' do
    context 'when an admin' do
      before { sign_in admin }

      it 'renders out all assisters' do
        get :index

        expect(response).to have_http_status :ok
        expect(assigns(:assisters)).to contain_exactly(admin, assister1, assister2)
      end
    end

    context 'when an assister' do
      before { sign_in assister1 }

      it 'cannot access the All Assisters page' do
        get :index
        expect(response).to have_http_status :found
      end

      it 'renders out all assisters in the same organization' do
        get :index, params: { organization_id: assister1.organization_id }

        expect(response).to have_http_status :ok
        expect(assigns(:assisters)).to contain_exactly(assister1)
      end
    end
  end

  describe '#new' do
    before { sign_in assister1 }

    it 'returns a 200 status' do
      get :new, params: { organization_id: assister1.organization_id }
      expect(response).to have_http_status :ok
    end
  end

  describe '#create' do
    before { sign_in assister1 }

    let(:user_params) { attributes_for :new_user }

    it 'creates a new user' do
      post :create, params: { user: user_params, organization_id: assister1.organization_id }

      user = assigns(:user)
      expect(user.name).to eq user_params[:name]
      expect(user.email).to eq user_params[:email]
    end
  end
end
