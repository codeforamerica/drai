class AssistersController < ApplicationController
  before_action :authenticate_user!

  def index
    @assisters = User.all.order(id: :desc)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.save

    respond_with @user, location: -> { assisters_path }, notice: "Sent invite to #{@user.email}"
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
