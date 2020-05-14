class OrganizationsController < ApplicationController
  before_action :authenticate_user!, only: :show
  before_action :authenticate_admin!, except: :show

  def index
    @organizations = Organization.all
  end

  def show
    @organization = Organization.find(params[:id])
    @aid_applications = aid_applications
  end

  private

  def current_organization
    @_current_organization ||= Organization.find(params[:id]) if params[:id]
  end

  def aid_applications
    applications = AidApplication.submitted.order(id: :desc).includes(:organization, :creator, :submitter)

    applications = applications.where(organization: current_organization)

    applications = applications.query(params[:term]) if params[:term].present?

    applications
  end
end
