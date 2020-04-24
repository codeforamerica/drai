class AssistersController < ApplicationController
  with_options if: :current_organization do
    before_action :authenticate_user!
    before_action :authenticate_supervisor!, only: [:new, :create, :edit, :update]
  end

  before_action :authenticate_admin!, unless: :current_organization

  def index
    query = User.all.order(id: :desc).includes(:organization)
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
    @user = User.new(new_user_params)
    if current_organization
      @user.organization = current_organization
      @user.inviter = current_user
    end

    @user.save

    respond_with @user, location: -> { current_organization ? organization_assisters_path(current_organization) : assisters_path }, notice: "Sent invite to #{@user.email}"
  end

  def edit
    @user = assister
  end

  def update
    @user = assister
    @user.update(update_user_params)
    respond_with @user, location: -> { current_organization ? organization_assisters_path(current_organization) : assisters_path }
  end

  private

  def new_user_params
    params.require(:user).permit(:name, :email, :organization_id, :supervisor)
  end

  def update_user_params
    params.require(:user).permit(:name, :email, :supervisor)
  end

  def assister
    if current_organization
      current_organization.users.find(params[:id])
    else
      User.find(params[:id])
    end
  end
end
