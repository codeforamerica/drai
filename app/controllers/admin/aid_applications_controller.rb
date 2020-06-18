module Admin
  class AidApplicationsController < ApplicationController
    before_action :authenticate_admin!

    LIMIT = 200

    def index
      @aid_applications = AidApplication.all
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
                            .limit(LIMIT)
    end
  end
end
