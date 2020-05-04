module AidApplications
  class EditsController < BaseController
    def edit
      @aid_application = current_aid_application

      if @aid_application.members.size == 0
        @aid_application.members.build
      end
    end

    def update
      @aid_application = current_aid_application
      @aid_application.attributes = aid_application_params

      if params[:form_action] == 'add_person'
        @aid_application.members.build
      end

      if params[:form_action] == 'submit'
        @aid_application.save_and_submit(submitter: current_user)
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
          :street_address,
          :city,
          :zip_code,
          :phone_number,
          :email,
          members_attributes: [
              :id,
              :name,
              :birthday,
              :preferred_language,
              :country_of_origin,
              :racial_ethnic_identity,
              :sexual_orientation,
              :gender,
              :_destroy
          ]
      )
    end
  end
end
