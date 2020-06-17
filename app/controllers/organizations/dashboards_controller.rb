module Organizations
  class DashboardsController < BaseController
    def show
      @organization = current_organization
      @aid_applications = @organization.aid_applications
                            .includes(
                              :organization,
                              :creator,
                              :submitter,
                              :approver,
                              :disburser,
                              :aid_application_waitlist
                            )
                            .visible
                            .filter_by_params(params)
                            .page(params[:page])
    end

    def current_organization
      @_current_organization ||= Organization.with_counts.find(params[:organization_id])
    end

    def low_on_cards?
      total_cards = @organization.total_payment_cards_count
      remaining_cards = total_cards - @organization.committed_aid_applications_count

      card_limit = case
                   when total_cards > 11_000
                     2000
                   when total_cards > 6000
                     1000
                   else
                     500
                   end

      (remaining_cards < card_limit) && remaining_cards.positive?
    end
    helper_method :low_on_cards?

    def no_cards?
      (@organization.total_payment_cards_count - @organization.disbursed_aid_applications_count) <= 0
    end
    helper_method :no_cards?

  end
end
