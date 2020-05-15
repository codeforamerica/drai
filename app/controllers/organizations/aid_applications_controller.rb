module Organizations
  class AidApplicationsController < BaseController
    def create
      @aid_application = AidApplication.create!(
          creator: current_user,
          organization: current_organization
      )

      respond_with @aid_application, location: -> { edit_organization_aid_application_eligibility_path(current_organization, @aid_application) }
    end

    def destroy
      @aid_application = current_organization.aid_applications.find(params[:id]) if params[:id]
      @aid_application.destroy!
      redirect_to organization_dashboard_path(current_organization)
    end

    private

    def aid_application_params
      params.require(:aid_application).permit(:street_address, :city, :zip_code, :phone_number, :email, :name, :birthday)
    end
  end
end
