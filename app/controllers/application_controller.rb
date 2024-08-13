class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:user_name, :display_name, :email])
      devise_parameter_sanitizer.permit(:sign_in, keys: [:user_name])
      devise_parameter_sanitizer.permit(:account_update, keys: [:display_name])
  end

  def after_sign_in_path_for(resource)
    blogs_path
  end
end
