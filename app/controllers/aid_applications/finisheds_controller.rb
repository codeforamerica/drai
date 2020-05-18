module AidApplications
  class FinishedsController < BaseController
    before_action :authenticate_supervisor!
    before_action do
      if current_aid_application.disbursed_at.blank?
        redirect_to edit_organization_aid_application_disbursement_path(current_organization, current_aid_application)
      end
    end


    def edit
      @aid_application = current_aid_application
    end
  end
end
