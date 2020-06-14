module AidApplications
  class ApprovalsController < BaseController
    before_action :authenticate_supervisor!
    before_action :authenticate_admin!, only: [:unapprove, :unreject]
    before_action :ensure_submitted
    before_action :prevent_double_approval, only: [:approve, :reject]
    before_action :prevent_double_rejection, only: [:approve, :reject]

    def edit
      @aid_application = current_aid_application
    end

    def approve
      @aid_application = current_aid_application
      app_is_duplicate = AidApplication.matching_approved_apps(@aid_application).any?

      if app_is_duplicate
        respond_with @aid_application, location: organization_aid_application_duplicate_path(current_organization, @aid_application)
      else
        @aid_application.save_and_approve(approver: current_user)
        @aid_application.send_approval_notification

        if params['form_action'] == 'approve_and_exit'
          respond_with @aid_application, location: organization_dashboard_path(current_organization), notice: "#{@aid_application.application_number} has been approved."
        else
          respond_with @aid_application, location: edit_organization_aid_application_disbursement_path(@aid_application.organization, @aid_application)
        end
      end
    end

    def reject
      @aid_application = current_aid_application
      @aid_application.save_and_reject(rejecter: current_user)

      respond_with @aid_application, location: organization_dashboard_path(current_organization), notice: "#{@aid_application.application_number} has been approved."
    end

    def unapprove
      if current_aid_application.disbursed?
        return redirect_to(action: :edit)
      end

      @aid_application = current_aid_application
      @aid_application.update!(
        approved_at: nil,
        approver: nil
      )

      redirect_to({ action: :edit }, notice: "#{@aid_application.application_number} has been un-approved.")
    end

    def unreject
      @aid_application = current_aid_application
      @aid_application.update!(
        rejected_at: nil,
        rejecter: nil
      )

      redirect_to({ action: :edit }, notice: "#{@aid_application.application_number} has been un-rejected.")
    end

    private

    def prevent_double_approval
      return if current_aid_application.approved_at.blank?
      redirect_to(action: :edit)
    end

    def prevent_double_rejection
      return if current_aid_application.rejected_at.blank?
      redirect_to(action: :edit)
    end
  end
end
