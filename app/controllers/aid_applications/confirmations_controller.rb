module AidApplications
  class ConfirmationsController < BaseController
    def edit
      @aid_application = current_aid_application
    end

    def update
      @aid_application = current_aid_application
      @aid_application.assign_attributes(aid_application_params)

      if params[:form_action] == 'update_and_resend'
        @aid_application.assign_attributes(aid_application_params)
        @aid_application.save(context: :contact_information)

        if @aid_application.errors.empty?
          @aid_application.send_submission_notification
        end

        return respond_with @aid_application, location: -> {edit_organization_aid_application_confirmation_path(current_organization, @aid_application)}
      else
        @aid_application.save(context: :confirmation)

        respond_with @aid_application, location: -> {organization_dashboard_path(current_organization)}
      end
    end

    private

    def aid_application_params
      params.require(:aid_application).permit(
          :contact_method_confirmed,
          :card_receipt_method,
          :phone_number,
          :email
      )
    end
  end
end
