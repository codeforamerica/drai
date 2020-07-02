module AidApplications
  class ApplicantsController < BaseController
    before_action :ensure_eligible_or_submitted
    before_action :ensure_submitted, if: -> { verify_page? }
    before_action :prevent_disbursed_modification, only: [:update]

    def edit
      @aid_application = current_aid_application

      @aid_application.preferred_language ||= set_preferred_language
      @aid_application.country_of_origin ||= AidApplication::DEMOGRAPHIC_OPTIONS_DEFAULT
      @aid_application.sexual_orientation ||= AidApplication::DEMOGRAPHIC_OPTIONS_DEFAULT
      @aid_application.gender ||= AidApplication::DEMOGRAPHIC_OPTIONS_DEFAULT
    end

    def update
      @aid_application = current_aid_application
      @aid_application.assign_attributes(aid_application_params)

      case params[:form_action]
      when 'allow_mailing_address'
        @aid_application.allow_mailing_address = true

        if @aid_application.submitted?
          @aid_application.save(context: :submit)
        else
          @aid_application.save
        end

        respond_with @aid_application, location: (lambda do
          if verify_page?
            edit_organization_aid_application_verification_path(current_organization, @aid_application, anchor: "mailing-address")
          else
            edit_organization_aid_application_applicant_path(current_organization, @aid_application, anchor: "mailing-address")
          end
        end)
      when 'remove_mailing_address'
        @aid_application.assign_attributes(
            allow_mailing_address: false,
            mailing_street_address: nil,
            mailing_apartment_number: nil,
            mailing_city: nil,
            mailing_state: nil,
            mailing_zip_code: nil
        )

        if @aid_application.submitted?
          @aid_application.save(context: :submit)
        else
          @aid_application.save
        end

        respond_with @aid_application, location: (lambda do
          if verify_page?
            edit_organization_aid_application_verification_path(current_organization, @aid_application, anchor: "address")
          else
            edit_organization_aid_application_applicant_path(current_organization, @aid_application, anchor: "address")
          end
        end)
      when 'submit'
        if @aid_application.submitted?
          redirect_to edit_organization_aid_application_confirmation_path(current_organization, @aid_application)
          return
        end

        app_is_duplicate_submitted = AidApplication.matching_submitted_apps(@aid_application).any?

        if app_is_duplicate_submitted
          @aid_application.save
          respond_with @aid_application, location: -> { organization_aid_application_duplicate_path(current_organization, @aid_application) }
        else
          @aid_application.save_and_submit(submitter: current_user)
          if @aid_application.errors.empty?
            @aid_application.send_submission_notification
          end

          respond_with @aid_application, location: -> { edit_organization_aid_application_confirmation_path(current_organization, @aid_application) }
        end
      when 'verify', 'verify_and_exit'
        @aid_application.record_verification_if_changed(verifier: current_user)
        @aid_application.save(context: :submit)

        app_is_duplicate_approved = AidApplication.matching_approved_apps(@aid_application).any?
        if app_is_duplicate_approved
          respond_with @aid_application, location: -> { organization_aid_application_duplicate_path(current_organization, @aid_application, verify: true) }
          return
        end

        respond_with @aid_application, location: (lambda do
          if params[:form_action] == 'verify_and_exit'
            organization_dashboard_path(current_organization)
          else
            edit_organization_aid_application_approval_path(current_organization, @aid_application)
          end
        end)
      else # update
        @aid_application.save(context: :submit)

        respond_with @aid_application, location: (lambda do
          if @aid_application.submitted?
            edit_organization_aid_application_confirmation_path(current_organization, @aid_application)
          else
            edit_organization_aid_application_applicant_path(current_organization, @aid_application)
          end
        end)
      end
    end

    def unpause
      @aid_application = current_aid_application
      @aid_application.save_and_unpause(unpauser: current_user)

      respond_with @aid_application, location: -> { edit_organization_aid_application_verification_path(current_organization, @aid_application) }, notice: "The application has been restarted."
    end

    def aid_application_params
      params.require(:aid_application).permit(
          :street_address,
          :apartment_number,
          :city,
          :zip_code,
          :county_name,
          :allow_mailing_address,
          :mailing_street_address,
          :mailing_apartment_number,
          :mailing_city,
          :mailing_state,
          :mailing_zip_code,
          :sms_consent,
          :email_consent,
          :phone_number,
          :confirmed_invalid_phone_number,
          :landline,
          :email,
          :confirmed_invalid_email,
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
          {racial_ethnic_identity: []},
          :sexual_orientation,
          :gender,
          :attestation,
          :verified_photo_id,
          :verified_proof_of_address,
          :verified_covid_impact,
          :verification_case_note

      ).each do |_, value|
        value.delete('') # removes arrays with empty string from checkboxes
      end
    end

    def set_preferred_language
      if params[:locale].present?
        AidApplication::LOCALE_LANGUAGE_MAPPING[params[:locale]]
      else
        AidApplication::DEMOGRAPHIC_OPTIONS_DEFAULT
      end
    end

    def verify_page?
      params[:verify]
    end
    helper_method :verify_page?

    def prevent_disbursed_modification
      return unless current_aid_application.disbursed?

      redirect_to organization_aid_application_path(current_organization, current_aid_application)
    end
  end
end
