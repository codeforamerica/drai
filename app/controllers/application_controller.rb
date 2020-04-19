class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html
end
