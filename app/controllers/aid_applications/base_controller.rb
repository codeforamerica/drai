module AidApplications
  class BaseController < ApplicationController
    def current_aid_application
      @_current_aid_application ||= current_organization.aid_applications.find(params[:aid_application_id]) if params[:aid_application_id]
    end
    helper_method :current_aid_application
  end
end
