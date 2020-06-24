module AidApplications
  class ConfirmationsController < BaseController
    before_action :ensure_submitted

    def edit
      @aid_application = current_aid_application
    end

    def update
      @aid_application = current_aid_application
      @aid_application.assign_attributes(aid_application_update_params)

      @aid_application.save(context: :confirmation)

      respond_with @aid_application, location: -> { organization_dashboard_path(current_organization) }
    end

    def update_contact_information
      @aid_application = current_aid_application
      @aid_application.assign_attributes(aid_application_update_contact_information_params)

      @aid_application.save(context: :contact_information)

      if @aid_application.errors.empty?
        @aid_application.send_submission_notification
      end

      respond_with @aid_application, location: -> { edit_organization_aid_application_confirmation_path(current_organization, @aid_application) }
    end

    private

    def aid_application_update_params
      params.require(:aid_application).permit(
        :contact_method_confirmed,
        :card_receipt_method
      )
    end

    def aid_application_update_contact_information_params
      params.fetch(:aid_application, {}).permit(
        :phone_number,
        :email
      )
    end
  end
end
