# frozen_string_literal: true

module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActionController::ParameterMissing, with: :handle_bad_request
    rescue_from ActiveRecord::RecordInvalid, with: :handle_unprocessable_entity
  end

  private

  def handle_not_found(error)
    render_error(
      message: "#{error.model} not found",
      status: :not_found
    )
  end

  def handle_bad_request(error)
    render_error(
      message: "Bad request",
      status: :bad_request,
      details: error.message
    )
  end

  def handle_unprocessable_entity(error)
    render_error(
      message: "Validation failed",
      status: :unprocessable_entity,
      details: error.record.errors.full_messages
    )
  end

  # 🔹 Helper for manual error rendering in controllers
  def render_error(message:, status:, details: nil)
    payload = { message: message }
    payload[:details] = details if details.present?
    render json: payload, status: status
  end
end
