module Organizations
  class BaseController < ApplicationController
    before_action :authenticate_user!

    def current_organization
      @_current_organization ||= Organization.find(params[:organization_id])
    end
  end
end
