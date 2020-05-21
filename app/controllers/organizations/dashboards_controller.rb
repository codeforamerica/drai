module Organizations
  class DashboardsController < BaseController
    def show
      @aid_applications = current_organization.aid_applications
                            .includes(:organization, :creator, :submitter, :approver, :disburser)
                            .submitted
                            .filter_by_params(params)
                            .page(params[:page])
    end

    def current_organization
      @_current_organization ||= Organization.with_counts.find(params[:organization_id])
    end
  end
end
