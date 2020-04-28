require 'rails_helper'

describe Account::AccountsController do
  let(:user) { create :user }

  describe '#show' do
    context 'when authenticated' do
      before { sign_in user }

      it 'renders out a form for the current user' do
        get :show
        expect(response).to have_http_status :ok
      end
    end

    context 'when unauthenticated' do
      it "redirects away" do
        get :show
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

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
  end

  describe '#update' do
    before { sign_in user }

    it 'saves the users password' do
      expect do
        put :update, params: { user: { current_password: 'password', password: 'qwerty', password_confirmation: 'qwerty' } }
      end.to change { user.reload.updated_at }

      expect(response).to redirect_to account_path
    end
  end
end
