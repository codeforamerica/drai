class HelloWorldsController < ApplicationController
  def show
    if current_user
      redirect_to redirect_to_organization_home_page(current_user)
    else
      redirect_to new_user_session_path
    end
  end
end
