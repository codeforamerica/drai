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

      if @user.errors.empty? && @user.setup?
        bypass_sign_in(@user) # do not sign out the user on password change
        redirect_to assisters_path
      else
        render :edit
      end
    end

    private

    def credentials
      params.require(:user).permit(:name, :password)
    end
  end
end
