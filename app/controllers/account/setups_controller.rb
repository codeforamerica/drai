module Account
  class SetupsController < ApplicationController
    def edit

    end

    def update
      @user = current_user
      @user.update(credentials)
      redirect_to root_path
    end

    private

    def credentials
      params.require(:user).permit(:password)
    end
  end
end
