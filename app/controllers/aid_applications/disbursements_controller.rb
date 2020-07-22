module AidApplications
  class DisbursementsController < BaseController
    before_action :authenticate_supervisor!
    before_action :ensure_approved

    before_action do
      if current_aid_application.disbursed_at.present?
        redirect_to edit_organization_aid_application_finished_path(current_organization, current_aid_application)
      elsif current_aid_application.approved_at.blank?
        redirect_to edit_organization_aid_application_approval_path(current_organization, current_aid_application)
      end
    end

    def edit
      @search_card = SearchCard.new
    end

    def update
      current_aid_application.update(aid_application_params)

      @search_card = SearchCard.new(search_card_params)

      payment_card = PaymentCard.find_by(sequence_number: @search_card.sequence_number.strip)

      if payment_card.blank?
        @search_card.errors.add(:sequence_number, t('activerecord.errors.messages.sequence_number_invalid'))
      elsif payment_card.aid_application.present?
        @search_card.errors.add(:sequence_number, t('activerecord.errors.messages.sequence_number_already_assigned', app_number: payment_card.aid_application.application_number, organization: payment_card.aid_application.organization.name))
      end

      unless @search_card.matching_sequence_numbers?
        @search_card.errors.add(:sequence_number_confirmation, t('activerecord.errors.messages.sequence_numbers_must_match'))
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

      redirect_to edit_organization_aid_application_finished_path(current_organization, current_aid_application)
    end

    private

    def search_card_params
      params.require(:search_card).permit(:sequence_number, :sequence_number_confirmation).except(:aid_application)
    end

    def aid_application_params
      params.require(:search_card).fetch(:aid_application, {}).permit(:card_receipt_method)
    end

    class SearchCard
      include ActiveModel::Model
      attr_accessor :sequence_number
      attr_accessor :sequence_number_confirmation

      def self.model_name
        ActiveModel::Name.new(self, nil, "SearchCard")
      end

      def matching_sequence_numbers?
        (sequence_number.presence || '').strip == (sequence_number_confirmation.presence || '').strip
      end
    end
  end
end
