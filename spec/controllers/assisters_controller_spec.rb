require 'rails_helper'

describe AssistersController, type: :controller do
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
      get :new
      expect(response).to have_http_status :ok
    end
  end

  describe '#create' do
    let(:user_params) { attributes_for :new_user }

    it 'creates a new user' do
      post :create, params: { user: user_params }

      user = assigns(:user)
      expect(user.name).to eq user_params[:name]
      expect(user.email).to eq user_params[:email]
    end
  end
end
