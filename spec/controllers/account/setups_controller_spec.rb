require 'rails_helper'

describe Account::SetupsController do
  let(:user) { create :user }

  describe '#edit' do
    before { sign_in user }

    it 'renders out a form for the current user' do
      get :edit
      expect(response).to have_http_status :ok
    end
  end

  describe '#update' do
    before { sign_in user }

    it 'saves the users password' do
      put :update, params: { user: { password: 'password' } }

      expect(user.reload.password_present?).to be true
    end
  end
end
