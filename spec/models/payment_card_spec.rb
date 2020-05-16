require 'rails_helper'

describe PaymentCard do
  it 'has a valid factory' do
    payment_card = build :payment_card
    expect(payment_card).to be_valid
  end
end
