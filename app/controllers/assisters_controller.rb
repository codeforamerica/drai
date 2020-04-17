class AssistersController < ApplicationController
  def index
    @assisters = User.all
  end
end
