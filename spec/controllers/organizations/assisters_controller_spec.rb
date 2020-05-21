require 'rails_helper'

describe Organizations::AssistersController, type: :controller do
  let!(:supervisor) { create :supervisor }
  let!(:assister) { create :assister, organization: supervisor.organization }
  let!(:another_assister) { create :assister }

  render_views

  describe '#index' do
    context 'when a supervisor' do
      before { sign_in supervisor }

      it 'renders out all assisters in the same organization' do
        get :index, params: { organization_id: supervisor.organization_id }

        expect(response).to have_http_status :ok
        expect(assigns(:users)).to contain_exactly(supervisor, assister)
      end
    end

    context 'when an assister' do
      before { sign_in assister }

      it 'redirects away' do
        get :index, params: { organization_id: assister.organization_id }
        expect(response).to have_http_status :found
      end
    end
  end

  describe '#new' do
    context 'when a supervisor' do
      before { sign_in supervisor }

      it 'returns a 200 status' do
        get :new, params: { organization_id: supervisor.organization_id }
        expect(response).to have_http_status :ok
      end
    end

    context 'when an assister' do
      before { sign_in assister }

      it 'redirects away' do
        get :new, params: { organization_id: assister.organization_id }
        expect(response).to have_http_status :found
      end
    end
  end

  describe '#create' do
    let(:user_params) { attributes_for :new_user }

    context 'when a supervisor' do
      before { sign_in supervisor }

      it 'creates a new user' do
        post :create, params: { user: user_params, organization_id: supervisor.organization_id }

        user = assigns(:user)
        expect(user.name).to eq user_params[:name]
        expect(user.email).to eq user_params[:email]
        expect(user.inviter).to eq supervisor
      end
    end

    context 'when an assister' do
      before { sign_in assister }

      it 'redirects away' do
        expect do
          post :create, params: { user: user_params, organization_id: assister.organization_id }
        end.not_to change(User, :count)
      end
    end
  end

  describe '#deactivate' do
    let(:supervisor) { create :supervisor }
    let(:assister) { create :assister, organization: supervisor.organization }

    context 'when a supervisor' do
      before { sign_in supervisor }

      it 'marks the user as deactivated' do
        expect do
          delete :deactivate, params: { organization_id: supervisor.organization.id, id: assister.id }
        end.to change { assister.reload.deactivated_at }.from(nil).to within(1.second).of Time.current

        expect(response).to redirect_to organization_assisters_path(supervisor.organization)
      end

      it 'cannot perform on itself' do
        expect do
          delete :deactivate, params: { organization_id: supervisor.organization.id, id: supervisor.id }
        end.not_to change { supervisor.reload.deactivated_at }
      end
    end

    context 'when an assister' do
      before { sign_in assister }

      it 'does nothing' do
        expect do
          delete :deactivate, params: { organization_id: supervisor.organization.id, id: assister.id }
        end.not_to change { assister.reload.deactivated_at }
      end
    end
  end

  describe '#reactivate' do
    let(:supervisor) { create :supervisor }
    let(:assister) { create :assister, organization: supervisor.organization, deactivated_at: 5.minutes.ago }

    context 'when a supervisor' do
      before { sign_in supervisor }

      it 'marks the user as deactivated' do
        expect do
          post :reactivate, params: { organization_id: supervisor.organization.id, id: assister.id }
        end.to change { assister.reload.deactivated_at }.to(nil)

        expect(response).to redirect_to organization_assisters_path(supervisor.organization)
      end

      it 'cannot perform on itself' do
        expect do
          post :reactivate, params: { organization_id: supervisor.organization.id, id: supervisor.id }
        end.not_to change { supervisor.reload.deactivated_at }
      end
    end

    context 'when an assister' do
      before { sign_in assister }

      it 'does nothing' do
        expect do
          post :reactivate, params: { organization_id: supervisor.organization.id, id: assister.id }
        end.not_to change { assister.reload.deactivated_at }
      end
    end
  end

  describe '#resend_confirmation_instructions' do
    let(:supervisor) { create :supervisor }
    let(:assister) { create :assister, organization: supervisor.organization, confirmed_at: nil }

    before { sign_in supervisor }

    it 'resends a confirmation email' do
      expect do
        post :resend_confirmation_instructions, params: { organization_id: supervisor.organization.id, id: assister.id }
      end.to enqueue_email
      expect(response).to redirect_to organization_assisters_path(supervisor.organization)
    end
  end

  describe '#send_password_reset_instructions' do
    let(:supervisor) { create :supervisor }
    let(:assister) { create :assister, organization: supervisor.organization }

    before { sign_in supervisor }

    it 'sends a password reset' do
      expect do
        post :send_password_reset_instructions, params: { organization_id: supervisor.organization.id, id: assister.id }
      end.to enqueue_email
      expect(response).to redirect_to organization_assisters_path(supervisor.organization)
    end
  end
end
