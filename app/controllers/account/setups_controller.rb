module Account
  class SetupsController < ApplicationController
    before_action :authenticate_user!
    before_action { redirect_to(edit_user_registration_path) if current_user.setup? }

    def edit
      @user = current_user
    end

    def update
      @user = current_user
      @user.attributes = credentials
      @user.save(context: :account_setup)

      respond_with @user, location: (lambda do
        bypass_sign_in(@user)

        if @user.organization
          organization_assisters_path(@user.organization)
        else
          assisters_path
        end
      end)
    end

    private

    def credentials
      params.require(:user).permit(:name, :password)
    end
  end
end
