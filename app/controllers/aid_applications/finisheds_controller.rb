module AidApplications
  class FinishedsController < BaseController
    before_action :authenticate_supervisor!
    before_action :ensure_disbursed

    def edit
      @aid_application = current_aid_application
    end

    def update
      @aid_application = current_aid_application

      if params[:form_action] == "resend_code"
        @aid_application.send_disbursement_notification
        respond_with @aid_application, location: -> {edit_organization_aid_application_finished_path(current_organization, current_aid_application)}, notice: "Activation Code re-sent"
      end

    end
  end
end
