require 'rails_helper'

RSpec.describe AidApplicationCleaner do
  describe '#delete_stale_and_unsubmitted' do
    it 'deletes unsubmitted aid applications that are more than 24 hours old' do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))

      submitted_application = create :aid_application, :submitted
      approved_application = create :aid_application, :approved
      disbursed_application = create :aid_application, :disbursed
      recent_application = create :aid_application, created_at: 1.hour.ago
      _old_unsubmitted_application = create :aid_application, created_at: 25.hour.ago
      AidApplicationCleaner.new.delete_stale_and_unsubmitted

      expect(AidApplication.all).to eq [submitted_application, approved_application, disbursed_application, recent_application]
    end
  end
end
