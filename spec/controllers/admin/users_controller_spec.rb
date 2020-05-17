require 'rails_helper'

describe Admin::UsersController, type: :controller do
  let(:admin) { create :admin }
  let!(:other_admins) { create_list :admin, 3}
  let(:supervisor) { create :supervisor }
  let!(:assister) { create :assister }
  let!(:another_assister) { create :assister }

  render_views

  describe '#index' do
    context 'when an admin' do
      before { sign_in admin }

      it 'renders out all assisters' do
        get :index

        expect(response).to have_http_status :ok
        expect(assigns(:users)).to contain_exactly(admin, assister, another_assister, *other_admins)
      end
    end
  end
end
