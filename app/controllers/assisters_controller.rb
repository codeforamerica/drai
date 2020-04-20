class AssistersController < ApplicationController
  before_action :authenticate_user!, if: :current_organization
  before_action :authenticate_admin!, unless: :current_organization

  def index
    query = User.all.order(id: :desc)
    @assisters = if current_organization
                   query.where(organization: current_organization)
                 else
                   query
                 end
  end

  def new
    @user = User.new(organization: current_organization)
  end

  def create
    @user = User.new(user_params)
    if current_organization
      @user.organization = current_organization
    end
    @user.save!

    respond_with @user, location: -> { current_organization ? organization_assisters_path(current_organization) : assisters_path }, notice: "Sent invite to #{@user.email}"
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :organization_id)
  end
end
