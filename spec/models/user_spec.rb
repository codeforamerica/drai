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

  describe '#organization' do
    it 'is required' do
      user = build :user, organization: nil
      expect(user.valid?).to be false
      expect(user.errors[:organization]).to be_present
    end

    it 'is required unless user is an admin' do
      user = build :user, organization: nil, admin: true
      expect(user.valid?).to be true
    end
  end

  describe '#admin' do
    it 'cannot be true if the user is a member of an organization' do
      user = build :user, organization: build(:organization)
      user.admin = true
      expect(user).not_to be_valid
      expect(user.errors[:admin]).to be_present
    end
  end

  describe '#supervisor' do
    it 'cannot be true if the user is NOT a member of an organization' do
      user = build :user, organization: nil
      user.supervisor = true
      expect(user).not_to be_valid
      expect(user.errors[:supervisor]).to be_present
    end
  end

  describe '#active_for_authentication?' do
    it 'is true if deactivated_at is nil' do
      user = build :user, deactivated_at: nil
      expect(user.active_for_authentication?).to eq true
    end

    it 'is false if deactivated_at is set' do
      user = build :user, deactivated_at: Time.current
      expect(user.active_for_authentication?).to eq false
    end
  end
end
