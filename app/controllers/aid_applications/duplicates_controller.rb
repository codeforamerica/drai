module AidApplications
  class DuplicatesController < BaseController
    def show
      @aid_application = current_aid_application
    end

    def verify_step?
      params[:verify]
    end
    helper_method :verify_step?

    def matching_apps
      AidApplication.matching_submitted_apps(@aid_application)
    end
  end
end
