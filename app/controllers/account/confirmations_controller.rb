module Account
  class ConfirmationsController < Devise::ConfirmationsController
    # GET /resource/confirmation/new
    # def new
    #   super
    # end

    # POST /resource/confirmation
    # def create
    #   super
    # end

    # GET /resource/confirmation?confirmation_token=abcdef
    def show
      super do |resource|
        # Automatically sign in the user after they confirm their email address
        # This is safe here because we are not allowing users to use their account
        # before confirming
        sign_in(resource) if resource.present? && resource.errors.empty?
      end
    end

    # protected

    # The path used after resending confirmation instructions.
    def after_resending_confirmation_instructions_path_for(_resource_name)
      flash.discard :notice # don't set a flash message, use template below
      root_path
    end

    # The path used after confirmation.
    def after_confirmation_path_for(_resource_name, _resource)
      flash.discard :notice # don't set a flash message, use template below
      edit_account_setup_path
    end
  end
end
