class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  def current_organization
    @_current_organization ||= Organization.find_by(id: params[:organization_id]) if params[:organization_id]
  end

  alias devise_authenticate_user! authenticate_user!

  def authenticate_user!
    devise_authenticate_user!
    return true if current_user.admin?

    if current_organization && current_organization != current_user.organization
      Rails.logger.error "User ##{current_user.id} is not allowed to access #{request.path}"
      redirect_to organization_path(current_user.organization)
    end
  end

  def authenticate_admin!
    devise_authenticate_user!
    return true if current_user.admin?

    Rails.logger.error "User ##{current_user.id} is not allowed to access #{request.path}"
    redirect_to organization_path(current_user.organization)
  end

  helper_method :current_organization

  def after_sign_in_path_for(user)
    stored_location = stored_location_for(user)

    if stored_location.present?
      stored_location
    elsif user.organization.present?
      organization_path(user.organization)
    else
      organizations_path
    end
  end
end

