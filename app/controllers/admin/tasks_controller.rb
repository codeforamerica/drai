class Admin::TasksController < ApplicationController
  before_action :authenticate_admin!

  before_action do
    @replace_payment_card = ReplacePaymentCard.new
  end

  def show
  end

  def replace_payment_card
    replace_payment_card_params = params.require(:replace_payment_card)
                                    .permit(
                                      :wrong_sequence_number,
                                      :correct_sequence_number
                                    )
    @replace_payment_card.assign_attributes(replace_payment_card_params)

    wrong_payment_card = PaymentCard.find_by(sequence_number: @replace_payment_card.wrong_sequence_number)
    correct_payment_card = PaymentCard.find_by(sequence_number: @replace_payment_card.correct_sequence_number)

    if wrong_payment_card.blank?
      @replace_payment_card.errors.add(:wrong_sequence_number, "Payment Card does not exist")
    elsif wrong_payment_card.aid_application.blank?
      @replace_payment_card.errors.add(:wrong_sequence_number, "Payment Card has not been disbursed")
    end

    if correct_payment_card.blank?
      @replace_payment_card.errors.add(:correct_sequence_number, "Payment Card does not exist")
    elsif correct_payment_card.aid_application.present?
      @replace_payment_card.errors.add(:wrong_sequence_number, "Payment Card has already been disbursed")
    end

    if @replace_payment_card.errors.empty?
      wrong_payment_card.replace_with(correct_payment_card)
      redirect_to({ action: :show }, notice: "Replaced Sequence Number '#{@replace_payment_card.wrong_sequence_number}' with '#{@replace_payment_card.correct_sequence_number}' for #{correct_payment_card.aid_application.application_number}")
    else
      render :show
    end
  end

  class ReplacePaymentCard
    include ActiveModel::Model
    attr_accessor :wrong_sequence_number
    attr_accessor :correct_sequence_number

    def self.model_name
      ActiveModel::Name.new(self, nil, "ReplacePaymentCard")
    end
  end
end
