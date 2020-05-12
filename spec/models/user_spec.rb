require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    user = build :user
    expect(user).to be_valid
  end

  describe '#password' do
    it 'must contain at least 1 uppercase, 1 lowercase, 1 number and 1 special character' do
      user = build :user, password: 'Password1!'
      expect(user).to be_valid

      user = build :user, password: 'password1!'
      expect(user).not_to be_valid

      user = build :user, password: 'PASSWORD1!'
      expect(user).not_to be_valid

      user = build :user, password: 'Passwordd!'
      expect(user).not_to be_valid

      user = build :user, password: 'Password12'
      expect(user).not_to be_valid
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
