require 'rails_helper'

describe Account::SetupsController do
  let(:user) { create :user, :unsetup }

  describe '#edit' do
    context 'when authenticated' do
      before { sign_in user }

      it 'renders out a form for the current user' do
        get :edit
        expect(response).to have_http_status :ok
      end
    end

    context 'when unauthenticated' do
      it "redirects away" do
        get :edit
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'when account already setup' do
      let(:user) { FactoryBot.create :user }

      it "redirects away" do
        sign_in user
        get :edit
        expect(response).to redirect_to edit_user_registration_path
      end
    end
  end

  describe '#update' do
    before { sign_in user }

    it 'saves the users password' do
      put :update, params: { user: { password: 'password' } }

      expect(user.reload.password_present?).to be true
      expect(response).to redirect_to edit_user_registration_path
    end
  end
end
