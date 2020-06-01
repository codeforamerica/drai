module AidApplications
  class DuplicatesController < BaseController
    def show
    end

    def verify_step?
      params[:verify]
    end
    helper_method :verify_step?
  end
end
