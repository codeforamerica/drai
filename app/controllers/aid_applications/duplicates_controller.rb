module AidApplications
  class DuplicatesController < BaseController
    before_action :authenticate_supervisor!, if: -> { verify_step? }

    def edit
      @aid_application = current_aid_application
    end

    def update
      @aid_application = current_aid_application

      matching_apps.each do |dupe|
        @aid_application.ignored_duplicates.find_or_create_by(duplicate_aid_application: dupe, user: current_user)
      end

      if verify_step?
        @aid_application.save_and_approve(approver: current_user)
        @aid_application.send_approval_notification

        respond_with @aid_application, location: edit_organization_aid_application_disbursement_path(@aid_application.organization, @aid_application)
      else
        @aid_application.save_and_submit(submitter: current_user)
        @aid_application.send_submission_notification

        respond_with @aid_application, location: -> { edit_organization_aid_application_confirmation_path(current_organization, @aid_application) }
      end
    end

    private

    def verify_step?
      current_aid_application.submitted?
    end
    helper_method :verify_step?

    def matching_apps
      verify_step? ? AidApplication.matching_approved_apps(@aid_application) : AidApplication.matching_submitted_apps(@aid_application)
    end
    helper_method :matching_apps
  end
end
