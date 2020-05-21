module Organizations
  class DashboardsController < BaseController
    def show
      aid_applications_query = current_organization.aid_applications
                                                   .includes(:organization, :creator, :submitter, :approver, :disburser)
                                                   .submitted
                                                   .page(params[:page])
                                                   .order_by(params[:status])
                                                   .limit(LIMIT)

      aid_applications_query = aid_applications_query.query(params[:term]) if params[:term].present?
      aid_applications_query = aid_applications_query.send(:"only_#{params[:status]}") if params[:status].present?

      @aid_applications = aid_applications_query
    end

    def current_organization
      @_current_organization ||= Organization.with_counts.find(params[:organization_id])
    end
  end
end
