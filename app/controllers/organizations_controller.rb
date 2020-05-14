class OrganizationsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @organizations = Organization.all
  end
end
