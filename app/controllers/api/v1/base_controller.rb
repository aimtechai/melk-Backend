class Api::V1::BaseController < ApplicationController
  # Disable CSRF for all API requests (no authenticity tokens for JSON APIs)
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  # Force JWT auth on all API calls by default
  before_action :authenticate_user!

  # Prevent Rails from falling back to cookies/sessions for auth
  before_action :skip_session

  private

  def skip_session
    request.session_options[:skip] = true
  end
end
