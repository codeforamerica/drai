module Organizations
  class DashboardsController < BaseController
    LIMIT = 200

    def show
      aid_applications_query = current_organization.aid_applications
                                                   .includes(:organization, :creator, :submitter, :approver, :disburser)
                                                   .submitted
                                                   .order(id: :desc)
                                                   .limit(LIMIT)
      aid_applications_query = aid_applications_query.query(params[:term]) if params[:term].present?

      @aid_applications = aid_applications_query
    end
  end
end
