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

  describe '#find_duplicates' do
    let(:member) { create :member }
    let(:duplicate) do
      duplicate = create :member, name: member.name, birthday: member.birthday
      duplicate.aid_application.update zip_code: member.aid_application.zip_code
      duplicate
    end

    it 'returns a member when there is a matching name, birthday and zip_code' do
      expect(member.find_duplicates).to contain_exactly duplicate
    end

  end
end
