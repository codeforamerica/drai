require 'rails_helper'

describe AidApplications::VerificationsController, type: :controller do
  let!(:assister) { create :assister }
  before { sign_in assister}

  render_views

  describe '#edit' do
    context 'when client is not a duplicate'
    context 'when client may be a duplicate' do
      let!(:member) { create :member }
      let(:duplicate) do
        duplicate = create :member, name: member.name, birthday: member.birthday
        duplicate.aid_application.update zip_code: member.aid_application.zip_code
        duplicate
      end

      it 'displays the duplicates on the page' do
        get :edit, params: { organization_id: member.aid_application.organization.id,
                             aid_application_id: member.aid_application.id }
        expect(response.body).to have_content "Potential Duplicate"
      end

    end
  end
end
