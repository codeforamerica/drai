class Admin::MessagesController < ApplicationController
  before_action :authenticate_admin!

  def index
    @organizations = Organization.all.with_counts.order(id: :asc)
  end
end
