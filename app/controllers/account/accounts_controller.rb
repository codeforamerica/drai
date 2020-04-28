module Account
  class AccountsController < ApplicationController
    before_action :authenticate_user!

    def show
      @user = current_user
    end

    def edit
      @user = current_user
    end

    def update
      @user = current_user
      @user.update_with_password(account_params)

      bypass_sign_in(@user) if @user.errors.empty?
      respond_with @user, location: -> { account_path }, notice: "Your account has been updated."
    end

    private

    def account_params
      params.require(:user).permit(:current_password, :password, :password_confirmation)
    end
  end
end
