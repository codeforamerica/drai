class AidApplicationsController < ApplicationController
  before_action :authenticate_user!

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
    {} # TODO: add aid application form
  end
end
