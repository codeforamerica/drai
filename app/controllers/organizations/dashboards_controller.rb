module Organizations
  class DashboardsController < BaseController
    def show
      @organization = current_organization
      @aid_applications = @organization.aid_applications
                            .includes(:organization, :creator, :submitter, :approver, :disburser)
                            .visible
                            .filter_by_params(params)
                            .page(params[:page])
    end

    def current_organization
      @_current_organization ||= Organization.with_counts.find(params[:organization_id])
    end

    def low_on_cards?
      total_cards = @organization.total_payment_cards_count

      card_limit = case
                   when total_cards > 11_000
                     2000
                   when total_cards > 6000
                     1000
                   when total_cards > 0
                     500
                   else
                     0 # TODO: what should happen when total cards are 0?
                   end

      (total_cards - @organization.total_aid_applications_count) < card_limit
    end
    helper_method :low_on_cards?

  end
end
