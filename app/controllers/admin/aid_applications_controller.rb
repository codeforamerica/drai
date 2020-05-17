module Admin
  class AidApplicationsController < ApplicationController
    before_action :authenticate_admin!

    def index
      aid_applications_query = AidApplication.submitted.includes(:organization, :creator, :submitter).order(id: :desc)
      aid_applications_query = applications.query(params[:term]) if params[:term].present?
      @aid_applications = aid_applications_query
    end
  end
end
