require 'rails_helper'

describe Member do
  it 'has a valid factory' do
    member = build :member
    expect(member).to be_valid
  end

  describe '#name' do
    it 'is required' do
      member = build :member, name: ''
      expect(member).not_to be_valid(:submit_aid_application)
    end
  end

  describe '#birthday' do
    it 'is required' do
      member = build :member, birthday: nil
      expect(member).not_to be_valid(:submit_aid_application)
    end
    it 'must be a date after 1900' do
      member = build :member, birthday: '01/01/1892'.to_date
      expect(member).not_to be_valid(:submit_aid_application)
    end
    it 'must be older than 18 years' do
      member = build :member, birthday: 15.years.ago
      expect(member).not_to be_valid(:submit_aid_application)
    end
  end
end
