module AidApplications
  class DisbursementsController < BaseController
    def edit
      @aid_application = current_aid_application
    end

    def update
      @aid_application = current_aid_application
    end
  end
end
