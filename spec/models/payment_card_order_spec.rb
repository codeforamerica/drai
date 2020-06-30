require 'rails_helper'

describe PaymentCardOrder do
  let(:organization) { create :organization }
  let(:payment_card) { create :payment_card }
  let(:payment_card_order) { create :payment_card_order, client_order_number: payment_card.client_order_number, organization: organization }

  it 'has all the associations' do
    expect(payment_card_order.organization).to eq organization
    expect(payment_card_order.payment_cards).to include(payment_card)

    expect(payment_card.payment_card_order).to eq payment_card_order
    expect(payment_card.client_order_organization).to eq organization

    expect(organization.payment_card_orders).to include(payment_card_order)
    expect(organization.ordered_payment_cards).to include(payment_card)
  end
end
