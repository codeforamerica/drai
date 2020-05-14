class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  before_action :set_paper_trail_whodunnit

  def current_organization
    @_current_organization ||= Organization.find_by(id: params[:organization_id]) if params[:organization_id]
  end
  helper_method :current_organization

  alias devise_authenticate_user! authenticate_user!

  def authenticate_user!(opts = {})
    devise_authenticate_user!(opts)
    return if current_user.admin?

    if current_organization && current_organization != current_user.organization
      Rails.logger.error "User ##{current_user.id} is not allowed to access #{request.path}"
      redirect_to organization_path(current_user.organization)
    end
  end

  def authenticate_supervisor!(opts = {})
    devise_authenticate_user!(opts)
    return if current_user.supervisor? || current_user.admin?

    Rails.logger.error "Non-Supervisor User ##{current_user.id} is not allowed to access #{request.path}"
    redirect_to organization_path(current_user.organization)
  end

  def authenticate_admin!(opts = {})
    devise_authenticate_user!(opts)
    return if current_user.admin?

    Rails.logger.error "Non-Admin User ##{current_user.id} is not allowed to access #{request.path}"
    redirect_to organization_path(current_user.organization)
  end

  def after_sign_in_path_for(user)
    stored_location = stored_location_for(user)

    if stored_location.present?
      stored_location
    else
      redirect_to_organization_home_page(user)
    end
  end

  def redirect_to_organization_home_page(user)
    if user.assister?
      organization_aid_applications_path(user.organization)
    elsif user.organization.present?
      organization_path(user.organization)
    else
      organizations_path
    end
  end
  helper_method :redirect_to_organization_home_page
end

