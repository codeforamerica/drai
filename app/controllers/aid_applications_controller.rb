class AidApplicationsController < ApplicationController
  before_action :authenticate_user!, if: :current_organization
  before_action :authenticate_admin!, unless: :current_organization

  def index
    @aid_applications = aid_applications
  end

  def create
    @aid_application = AidApplication.create!(
      creator: current_user,
      organization: current_organization
    )

    respond_with @aid_application, location: -> { edit_organization_aid_application_eligibility_path(current_organization, @aid_application) }
  end

  private

  def aid_applications
    applications = AidApplication.all.order(id: :desc).includes(:organization, :creator, :submitter)

    if current_organization
      applications = applications.where(organization: current_organization)
    end

    applications = applications.query(params[:term]) if params[:term].present?

    applications
  end

  def aid_application_params
    params.require(:aid_application).permit(:street_address, :city, :zip_code, :phone_number, :email, :name, :birthday)
  end
end
