class Organizations::MessagesController < ApplicationController
  before_action :authenticate_supervisor!

  def edit
    @organization = current_organization
  end

  def update
    @organization = current_organization
    @organization.update(organization_params)

    respond_with @organization,
                 location: -> { edit_organization_messages_path(current_organization) },
                 notice: "Messages have been updated"
  end

  def message_locales
    Rails.application.config.i18n.available_locales.select do |locale|
      @organization.has_attribute? attribute_from_locale(locale)
    end
  end
  helper_method :message_locales

  def attribute_from_locale(locale)
    :"submission_message_#{locale}"
  end
  helper_method :attribute_from_locale

  def organization_params
    params.require(:organization).permit(*message_locales.map { |locale| attribute_from_locale(locale) })
  end
end
