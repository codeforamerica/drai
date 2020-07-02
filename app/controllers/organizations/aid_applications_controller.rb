module Organizations
  class AidApplicationsController < BaseController
    before_action :prevent_disbursed_destruction, only: [:destroy]

    def show
      aid_application = current_aid_application

      if current_user.supervisor?
        if aid_application.disbursed?
          redirect_to edit_organization_aid_application_finished_path(current_organization, aid_application)
        elsif aid_application.approved? || aid_application.rejected?
          redirect_to edit_organization_aid_application_disbursement_path(current_organization, aid_application)
        elsif aid_application.verified?
          redirect_to edit_organization_aid_application_approval_path(current_organization, aid_application)
        else
          redirect_to edit_organization_aid_application_verification_path(current_organization, aid_application)
        end
      else
        redirect_to edit_organization_aid_application_confirmation_path(current_organization, aid_application)
      end
    end

    def create
      @aid_application = AidApplication.create!(
          creator: current_user,
          organization: current_organization
      )

      respond_with @aid_application, location: -> { edit_organization_aid_application_eligibility_path(current_organization, @aid_application) }
    end

    def destroy
      @aid_application = current_aid_application
      @aid_application.destroy!

      redirect_to organization_dashboard_path(current_organization)
    end

    private

    def current_aid_application
      @_current_aid_application ||= current_organization.aid_applications.find(params[:id]) if params[:id]
    end

    def prevent_disbursed_destruction
      return unless current_aid_application.disbursed?

      redirect_to organization_aid_application_path(current_organization, current_aid_application)
    end
  end
end
