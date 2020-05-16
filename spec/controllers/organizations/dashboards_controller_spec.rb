require 'rails_helper'

describe Organizations::DashboardsController do
  let(:assister) { create :assister }
  let(:other_assister) { create :assister }
  let(:admin) { create :admin }
  let!(:application1) { create :aid_application, :submitted }
  let!(:application2) { create :aid_application, :submitted }

  describe '#show' do
    context 'when invalid organization id' do
      before { sign_in application1.creator }

      it 'raises a not found error' do
        expect do
          get :show, params: { organization_id: application2.id + 99 }
        end.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context 'when an assister' do
      before { sign_in application1.creator }

      it 'returns a 200 status' do
        get :show, params: { organization_id: application1.creator.organization.id }
        expect(response).to have_http_status :ok
      end

      it "shows all submitted aid applications in the assister's organization" do
        get :show, params: { organization_id: application1.creator.organization.id }

        expect(response).to have_http_status :ok
        expect(assigns(:aid_applications)).to contain_exactly(application1)
      end
    end

    context 'when an assister in a different organization' do
      before { sign_in other_assister }

      it 'is redirected away' do
        get :show, params: { organization_id: assister.organization.id }
        expect(response).to have_http_status :found
      end
    end

    context 'when an admin' do
      before { sign_in admin }

      it 'returns a 200 status' do
        get :show, params: { organization_id: assister.organization.id }
        expect(response).to have_http_status :ok
      end
    end
  end
end
