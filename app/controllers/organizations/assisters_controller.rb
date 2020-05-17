module Organizations
  class AssistersController < ApplicationController
    before_action :authenticate_supervisor!
    before_action :prevent_self_action, only: [:deactivate, :reactivate, :resend_confirmation_instructions]

    def index
      users_query = current_organization.users.includes(:organization).order(id: :desc)

      @users = users_query.activated
      @deactivated_users = users_query.deactivated
    end

    def new
      @user = User.new(organization: current_organization)
    end

    def create
      @user = User.new(user_params.merge(
        organization: current_organization,
        inviter: current_user
      ))
      @user.save

      respond_with @user, location: -> { organization_assisters_path(current_organization) }, notice: "Sent invite to #{@user.email}"
    end

    def edit
      @user = user_from_params
    end

    def update
      @user = user_from_params
      @user.update(user_params)
      respond_with @user, location: -> { organization_assisters_path(current_organization) }
    end

    def deactivate
      @user = user_from_params
      @user.update(deactivated_at: Time.current) if @user.deactivated_at.nil?

      respond_with @user, notice: "Deactivated #{@user.name}", location: -> { organization_assisters_path(current_organization) }
    end

    def reactivate
      @user = user_from_params
      @user.update(deactivated_at: nil) if @user.deactivated_at.present?

      respond_with @user, notice: "Reactivated #{@user.name}", location: -> { organization_assisters_path(current_organization) }
    end

    def resend_confirmation_instructions
      @user = user_from_params
      if @user.confirmed_at.blank?
        @user.send_confirmation_instructions
      end
      respond_with @user, notice: "Resent confirmation for #{@user.name}", location: -> { organization_assisters_path(current_organization) }
    end

    private

    def prevent_self_action
      redirect_back(fallback_location: root_path) if user_from_params == current_user
    end

    def user_params
      params.require(:user).permit(:name, :email, :supervisor)
    end

    def user_from_params
      @_user_from_params ||= current_organization.users.find(params[:id])
    end
  end
end
