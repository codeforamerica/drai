class Admin::UsersController < ApplicationController
  before_action :authenticate_admin!

  def index
    @users = User.includes(:organization).all
  end
end
