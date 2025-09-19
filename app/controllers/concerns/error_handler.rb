# frozen_string_literal: true

module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActionController::ParameterMissing, with: :handle_bad_request
    rescue_from ActiveRecord::RecordInvalid, with: :handle_unprocessable_entity
  end

  private

  # Not found errors
  def handle_not_found(error)
    render json: { message: "#{error.model} not found" }, status: :not_found
  end

  # Missing or invalid params
  def handle_bad_request(error)
    render json: { message: "Bad request", details: error.message }, status: :bad_request
  end

  # Validation failures
  def handle_unprocessable_entity(error)
    render json: {
      message: "Validation failed",
      details: error.record.errors.full_messages
    }, status: :unprocessable_entity
  end

  # Manual helper for controller actions
  def render_error(message:, status:, details: nil)
    payload = { message: message }
    payload[:details] = details if details.present?
    render json: payload, status: status
  end
end
