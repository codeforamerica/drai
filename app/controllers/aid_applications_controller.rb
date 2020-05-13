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

  def edit
    @aid_application = current_organization.aid_applications.find(params[:id])
  end

  def update
    @aid_application = current_organization.aid_applications.find(params[:id])
    @aid_application.attributes = aid_application_params

    @aid_application.save

    if params[:form_action] == 'submit'
      @aid_application.save(context: :submit)
    end

    respond_with @aid_application, location: (lambda do
      if params[:form_action] == 'submit'
        organization_aid_applications_path(current_organization)
      else
        edit_organization_aid_application_path(current_organization, @aid_application)
      end
    end)
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
