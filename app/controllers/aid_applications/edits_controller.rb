module AidApplications
  class EditsController < BaseController
    def edit
      @aid_application = current_aid_application

      @aid_application.country_of_origin ||= AidApplication::DEMOGRAPHIC_OPTIONS_DEFAULT
      @aid_application.sexual_orientation ||= AidApplication::DEMOGRAPHIC_OPTIONS_DEFAULT
      @aid_application.gender ||= AidApplication::DEMOGRAPHIC_OPTIONS_DEFAULT
    end

    def update
      @aid_application = current_aid_application
      @aid_application.assign_attributes(aid_application_params)

      if params[:form_action] == 'submit'
        @aid_application.save_and_submit(submitter: current_user)

        if @aid_application.errors.empty?
          ApplicationTexter.basic_message(to: @aid_application.phone_number, body: I18n.t('text_message.app_id.body', app_id: @aid_application.application_number)).deliver_now
        end
      else
        @aid_application.save
      end

      respond_with @aid_application, location: (lambda do
        if @aid_application.submitted?
          edit_organization_aid_application_verification_path(current_organization, @aid_application)
        else
          edit_organization_aid_application_edit_path(current_organization, @aid_application)
        end
      end)
    end

    def aid_application_params
      params.require(:aid_application).permit(
          :valid_work_authorization,
          :covid19_reduced_work_hours,
          :covid19_care_facility_closed,
          :covid19_experiencing_symptoms,
          :covid19_underlying_health_condition,
          :covid19_caregiver,
          :street_address,
          :city,
          :zip_code,
          :preferred_contact_channel,
          :text_phone_number,
          :voice_phone_number,
          :phone_number,
          :email,
          :receives_calfresh_or_calworks,
          :unmet_food,
          :unmet_housing,
          :unmet_childcare,
          :unmet_utilities,
          :unmet_transportation,
          :unmet_other,
          :name,
          :birthday,
          :preferred_language,
          :country_of_origin,
          { racial_ethnic_identity: [] },
          :sexual_orientation,
          :gender,
      ).each do |_, value|
        value.delete('') # removes arrays with empty string from checkboxes
      end
    end
  end
end
