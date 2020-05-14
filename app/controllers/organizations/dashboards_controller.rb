module Organizations
  class DashboardsController < BaseController
    def show
      @aid_applications = aid_applications
    end

    private

    def aid_applications
      applications = AidApplication.submitted.order(id: :desc).includes(:organization, :creator, :submitter)

      applications = applications.where(organization: current_organization)

      applications = applications.query(params[:term]) if params[:term].present?

      applications
    end
  end
end