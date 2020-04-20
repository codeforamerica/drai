class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  def current_organization
    @_current_organization ||= Organization.find_by(id: params[:organization_id]) if params[:organization_id]
  end
  helper_method :current_organization

  def after_sign_in_path_for(user)
    default_path = if user.organization.present?
                     organization_path(user.organization)
                   else
                     organizations_path
                   end

    stored_location_for(user) || default_path
  end
end
