module AidApplications
  class DisbursementsController < BaseController
    before_action :authenticate_supervisor!
    before_action do
      if current_aid_application.disbursed_at.present?
        redirect_to edit_organization_aid_application_finished_path(current_organization, current_aid_application)
      end
    end

    def edit
      @search_card = SearchCard.new
    end

    def update
      @search_card = SearchCard.new(search_card_params)

      payment_card = PaymentCard.find_by(sequence_number: @search_card.sequence_number.strip)

      if payment_card.blank?
        @search_card.errors.add(:sequence_number, t('activerecord.errors.messages.sequence_number_invalid'))
      elsif payment_card.aid_application.present?
        @search_card.errors.add(:sequence_number, t('activerecord.errors.messages.sequence_number_already_assigned'))
      end

      if @search_card.errors.any?
        render :edit
        return
      end

      PaymentCard.transaction(joinable: false, requires_new: true) do
        payment_card.update!(
          aid_application: current_aid_application,
          activation_code: payment_card.generate_activation_code
        )
        current_aid_application.update!(
          disbursed_at: Time.current,
          disburser: current_user
        )
        AssignActivationCodeJob.perform_later(payment_card: payment_card)
      end

      current_aid_application.send_disbursement_notification

      redirect_to edit_organization_aid_application_finished_path(current_organization, current_aid_application)
    end

    private

    def search_card_params
      params.require(:search_card).permit(:sequence_number)
    end

    class SearchCard
      include ActiveModel::Model
      attr_accessor :sequence_number

      def self.model_name
        ActiveModel::Name.new(self, nil, "SearchCard")
      end
    end
  end
end
