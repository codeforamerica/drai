module AidApplications
  class FinishedsController < BaseController
    before_action :authenticate_supervisor!
    before_action :ensure_disbursed

    def edit
      @aid_application = current_aid_application
      @reveal_activation_code = flash[:reveal_activation_code]
    end

    def update
      @aid_application = current_aid_application
      @aid_application.assign_attributes(aid_application_update_contact_information_params)

      saved = @aid_application.save(context: :contact_information)
      if saved
        @aid_application.send_disbursement_notification
      end

      respond_with @aid_application, location: -> {edit_organization_aid_application_finished_path(current_organization, current_aid_application)}, notice: "Activation Code re-sent"
    end

    def reveal_activation_code
      RevealActivationCodeLog.create!(
        aid_application: current_aid_application,
        user: current_user
      )

      redirect_to({ action: :edit, anchor: 'reveal-activation-code' }, flash: { reveal_activation_code: true })
    end

    private

    def aid_application_update_contact_information_params
      params.require(:aid_application).permit(
        :phone_number,
        :email
      )
    end
  end
end
