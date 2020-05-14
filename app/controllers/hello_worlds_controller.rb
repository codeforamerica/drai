class HelloWorldsController < ApplicationController
  before_action :authenticate_user!, only: :show

  def show
    redirect_to redirect_to_organization_home_page(current_user)
  end
end
