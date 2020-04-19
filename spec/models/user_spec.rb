require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#password_required?' do
    it 'is false if password is not set up' do
      user = create :user, password: nil
      expect(user.password_required?).to be false
    end

    it 'is true if password has a previous value ' do
      user = create :user, password: 'password'
      expect(user.password_required?).to be true
    end
  end
end
