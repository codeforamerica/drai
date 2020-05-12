module AidApplications
  class ApprovalsController < BaseController
    def edit
      @aid_application = current_aid_application
    end

    def update
      @aid_application = current_aid_application
      @aid_application.save_and_approve(approver: current_user)

      respond_with @aid_application, location: -> { edit_organization_aid_application_disbursement_path(@aid_application.organization, @aid_application) }
    end
  end
end
