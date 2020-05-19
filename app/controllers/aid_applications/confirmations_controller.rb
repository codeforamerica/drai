module AidApplications
  class ConfirmationsController < BaseController
    def edit
      @aid_application = current_aid_application
    end

    def update
      @aid_application = current_aid_application
      @aid_application.assign_attributes(aid_application_params)
      @aid_application.save(context: :confirmation)

      respond_with @aid_application, location: -> { organization_dashboard_path(current_organization) }
    end

    private

    def aid_application_params
      params.require(:aid_application).permit(
          :contact_method_confirmed,
          :card_receipt_method
      )
    end
  end
end
