module AidApplications
  class FinishedsController < BaseController
    def edit
      @aid_application = current_aid_application
    end
  end
end
