module Account
  class SetupsController < ApplicationController
    before_action :authenticate_user!
    before_action { redirect_to(account_path) if current_user.setup? }

    def edit
      @user = current_user
    end

    def update
      @user = current_user
      @user.attributes = credentials
      @user.save(context: :account_setup)

      bypass_sign_in(@user) if @user.errors.empty?
      respond_with @user, location: -> { homepage_path(@user) }
    end

    private

    def credentials
      params.require(:user).permit(:name, :password)
    end
  end
end
