class HelloWorldsController < ApplicationController
  def show
    if current_user
      redirect_to homepage_path(current_user)
    else
      redirect_to new_user_session_path
    end
  end
end
