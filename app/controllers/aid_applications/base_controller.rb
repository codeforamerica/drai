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
  end
end
