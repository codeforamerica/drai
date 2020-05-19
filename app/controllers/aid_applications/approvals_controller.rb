module AidApplications
  class ApprovalsController < BaseController
    before_action :authenticate_supervisor!

    def edit
      @aid_application = current_aid_application
    end

    def update
      @aid_application = current_aid_application
      @aid_application.save_and_approve(approver: current_user)

      if params['form_action'] == 'approve_and_exit'
        respond_with @aid_application, location: organization_dashboard_path(current_organization), notice: "#{@aid_application.application_number} has been approved."
      else
        respond_with @aid_application, location: edit_organization_aid_application_disbursement_path(@aid_application.organization, @aid_application)
      end
    end
  end
end
