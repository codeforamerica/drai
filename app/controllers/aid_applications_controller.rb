class AidApplicationsController < ApplicationController
  before_action :authenticate_user!, if: :current_organization
  before_action :authenticate_admin!, unless: :current_organization

  def index
    query = AidApplication.all.order(id: :desc).includes(:organization, :assister)
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

    respond_with @aid_application, location: -> { organization_aid_application_edit_path(current_organization, @aid_application) }
  end
end
