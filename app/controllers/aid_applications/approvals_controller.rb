module AidApplications
  class ApprovalsController < BaseController
    before_action :authenticate_supervisor!

    def edit
      @aid_application = current_aid_application
    end

    def update
      @aid_application = current_aid_application
      app_is_duplicate = AidApplication.matching_approved_apps(@aid_application).any?

      if app_is_duplicate
        respond_with @aid_application, location: -> { organization_aid_application_duplicate_path(current_organization, @aid_application) }
      else
        @aid_application.save_and_approve(approver: current_user)

        respond_with @aid_application, location: (lambda do
          if Rails.env.production? || Rails.env.demo?
            # TODO: Finish Disbursement
            homepage_path(current_user)
          else
            edit_organization_aid_application_disbursement_path(@aid_application.organization, @aid_application)
          end
        end), notice: "#{@aid_application.application_number} has been approved."
      end
    end
  end
end
