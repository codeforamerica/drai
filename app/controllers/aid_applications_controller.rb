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

  def create
    @aid_application = AidApplication.create!(
      assister: current_user,
      organization: current_organization
    )

    respond_with @aid_application, location: -> { edit_organization_aid_application_path(current_organization, @aid_application) }
  end

  def edit
    @aid_application = current_organization.aid_applications.find(params[:id])
    if @aid_application.members.size == 0
      @aid_application.members.build
    end
  end

  def update
    @aid_application = current_organization.aid_applications.find(params[:id])
    @aid_application.attributes = aid_application_params

    if params[:form_action] == 'add_person'
      @aid_application.members.build
    end

    @aid_application.save

    if params[:form_action] == 'submit'
      @aid_application.save(context: :submit_aid_application)
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

  def aid_application_params
    params.require(:aid_application).permit(:street_address, :city, :zip_code, :phone_number, :email, members_attributes: [:id, :name, :birthday, :_destroy])
  end
end
