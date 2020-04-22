class AidApplicationsController < ApplicationController
  before_action :authenticate_user!, if: :current_organization
  before_action :authenticate_admin!, unless: :current_organization

  def index
    query = AidApplication.all.order(id: :desc)
    @aid_applications = if current_organization
                          query.where(organization: current_organization)
                        else
                          query
                        end
  end

  def new
    @aid_application = AidApplication.new(assister: current_user, organization: current_organization)
    2.times { @aid_application.members.build }
  end

  def create
    @aid_application = AidApplication.create(aid_application_params.merge(
      assister: current_user,
      organization: current_organization
    ))

    respond_with @aid_application, location: -> { organization_aid_applications_path }
  end

  private

  def aid_application_params
    params.require(:aid_application).permit(:street_address, :city, :zip_code, :phone_number, :email, members_attributes: [:id, :name, :birthday])
  end
end
