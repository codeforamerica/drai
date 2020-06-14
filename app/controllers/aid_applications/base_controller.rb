module AidApplications
  class BaseController < ApplicationController
    before_action :authenticate_user!

    def current_organization
      @_current_organization ||= Organization.find(params[:organization_id])
    end

    def current_aid_application
      @_current_aid_application ||= current_organization.aid_applications.find(params[:aid_application_id])
    end
    helper_method :current_aid_application

    def ensure_eligible_or_submitted
      return if current_aid_application.eligible? || current_aid_application.submitted?

      redirect_to edit_organization_aid_application_eligibility_path(current_organization, current_aid_application)
    end

    def ensure_submitted
      return if current_aid_application.submitted?

      redirect_to edit_organization_aid_application_applicant_path(current_organization, current_aid_application)
    end

    def ensure_approved
      return if current_aid_application.approved?

      redirect_to edit_organization_aid_application_approval_path(current_organization, current_aid_application)
    end

    def ensure_disbursed
      return if current_aid_application.disbursed?

      redirect_to edit_organization_aid_application_disbursement_path(current_organization, current_aid_application)
    end
  end
end
