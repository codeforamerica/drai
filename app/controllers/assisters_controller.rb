class AssistersController < ApplicationController
  before_action :authenticate_user!

  def index
    query = User.all.order(id: :desc)
    @assisters = if current_organization
                   query.where(organization: current_organization)
                 else
                   query
                 end
  end

  def new
    @organizations = Organization.all.order(name: :asc)
    @user = User.new(organization: current_organization)
  end

  def create
    @organizations = Organization.all.order(name: :asc)
    @user = User.new(user_params.merge(organization: current_organization))
    @user.save

    respond_with @user, location: -> { current_organization ? organization_assisters_path(current_organization) : assisters_path }, notice: "Sent invite to #{@user.email}"
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
