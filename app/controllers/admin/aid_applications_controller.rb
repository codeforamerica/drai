module Admin
  class AidApplicationsController < ApplicationController
    before_action :authenticate_admin!

    LIMIT = 200

    def index
      aid_applications_query = AidApplication.includes(:organization, :creator, :submitter, :approver, :disburser)
                                 .submitted
                                 .order(id: :desc)
                                 .limit(LIMIT)
      aid_applications_query = applications.query(params[:term]) if params[:term].present?
      @aid_applications = aid_applications_query
    end
  end
end
