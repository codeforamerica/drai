require 'rails_helper'

RSpec.describe SendApplicationNumberNotificationJob, type: :job do
  let!(:aid_application) { create :aid_application, phone_number: '5555551212' }

  describe 'send application_id to the client' do
    it 'enqueues the job' do
      described_class.perform_later(@aid_application)
      expect(described_class).to have_been_enqueued
    end
  end
end
