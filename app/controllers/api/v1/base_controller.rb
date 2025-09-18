class Api::V1::BaseController < ApplicationController
  include Pundit::Authorization

  respond_to :json

  protect_from_forgery with: :null_session
  before_action :authenticate_user!

  # skip_before_action :verify_authenticity_token

  rescue_from Pundit::NotAuthorizedError do
    render json: { error: "Forbidden" }, status: :forbidden
  end

  # # Prevent Rails from falling back to cookies/sessions for auth
  # before_action :skip_session

  # private

  # def skip_session
  #   request.session_options[:skip] = true
  # end
end
