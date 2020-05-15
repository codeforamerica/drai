class AidApplicationsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @aid_applications = aid_applications
  end

  private

  def aid_applications
    applications = AidApplication.all.order(id: :desc).includes(:organization, :creator, :submitter)

    applications = applications.query(params[:term]) if params[:term].present?

    applications
  end
end