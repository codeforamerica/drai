module AidApplications
  class FinishedsController < BaseController
    before_action :authenticate_supervisor!

    def edit
      @aid_application = current_aid_application
    end
  end
end
