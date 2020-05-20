class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  before_action :set_paper_trail_whodunnit

  around_action :switch_locale

  def switch_locale(&action)
    locale = params[:new_locale] || params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  # This needs to be a class method for the devise controller to have access to it
  # See: http://stackoverflow.com/questions/12550564/how-to-pass-locale-parameter-to-devise
  def self.default_url_options
    { locale: I18n.locale }.merge(super)
  end

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
      redirect_to homepage_path(current_user)
    end
  end

  def authenticate_supervisor!(opts = {})
    devise_authenticate_user!(opts)
    return if current_user.supervisor? || current_user.admin?

    Rails.logger.error "Non-Supervisor User ##{current_user.id} is not allowed to access #{request.path}"
    redirect_to homepage_path(current_user)
  end

  def authenticate_admin!(opts = {})
    devise_authenticate_user!(opts)
    return if current_user.admin?

    Rails.logger.error "Non-Admin User ##{current_user.id} is not allowed to access #{request.path}"
    redirect_to homepage_path(current_user)
  end

  def supervisor_visible?
    current_user.supervisor? || current_user.admin?
  end
  helper_method :supervisor_visible?

  def after_sign_in_path_for(user)
    stored_location = stored_location_for(user)

    if stored_location.present?
      stored_location
    else
      homepage_path(user)
    end
  end

  def homepage_path(user = current_user)
    return root_path if user.blank?

    if user.organization.present?
      organization_dashboard_path(user.organization)
    else
      admin_organizations_path
    end
  end
  helper_method :homepage_path
end

