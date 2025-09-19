class Api::V1::BaseController < ApplicationController
  respond_to :json

  include Pundit::Authorization
  include ErrorHandler

  protect_from_forgery with: :null_session
  before_action :authenticate_user!

  rescue_from Pundit::NotAuthorizedError do
    render_error(
      message: "Forbidden",
      status: :forbidden
    )
  end

  # Prevent Rails from falling back to cookies/sessions for auth
  # before_action :skip_session

  # def skip_session
  #   request.session_options[:skip] = true
  # end
end
