class ApplicationController < ActionController::Base
  include Pagy::Backend
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user

  def current_user
    @current_user ||= User.last
  end

  private

  def require_user
    return if current_user.present?

    render plain: "No user found. Run `bin/rails dev:seed` to create one.", status: :service_unavailable
  end
end
