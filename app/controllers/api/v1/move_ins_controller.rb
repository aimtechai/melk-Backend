# app/controllers/api/v1/move_ins_controller.rb
class Api::V1::MoveInsController < Api::V1::BaseController
  before_action :set_move_in, only: %i[show destroy update_status destroy_attachment]

  # GET /api/v1/move_ins
  def index
    records = current_user.move_ins
    render_serialized(records, :index, :ok)
  end

  # GET /api/v1/move_ins/:id
  def show
    render_serialized(@move_in, :show, :ok)
  end

  # PUT /api/v1/move_ins/upsert
  # Create if none exists, otherwise update existing
  def upsert
    record = current_user.move_ins.last

    if record.nil?
      record = current_user.move_ins.new(move_in_params)
      action = :create
    else
      record.assign_attributes(move_in_params)
      action = :update
    end

    if scheduling_present?(record) && !record.checklist_complete?
      return render_error(message: "Complete checklist before scheduling", status: :unprocessable_entity)
    end

    if record.save
      render_serialized(record, action, :ok)
    else
      render_error(
        message: "Failed to #{action == :create ? 'create' : 'update'} move-in",
        status: :unprocessable_entity,
        details: record.errors.full_messages
      )
    end
  end

  # DELETE /api/v1/move_ins/:id
  def destroy
    if @move_in.destroy
      render json: { message: "Move-in deleted successfully" }, status: :ok
    else
      render_error(
        message: "Failed to delete move-in",
        status: :unprocessable_entity,
        details: @move_in.errors.full_messages
      )
    end
  end

  # PATCH /api/v1/move_ins/:id/update_status
  def update_status
    status_value = params.dig(:move_in, :status) || params[:status]

    unless MoveIn.statuses.keys.include?(status_value.to_s)
      return render_error(message: "Invalid status", status: :bad_request)
    end

    if @move_in.update(status: status_value)
      render_serialized(@move_in, :update_status, :ok)
    else
      render_error(
        message: "Failed to update status",
        status: :unprocessable_entity,
        details: @move_in.errors.full_messages
      )
    end
  end

  # DELETE specific attachment
  def destroy_attachment
    att = @move_in.attachments.find_by(id: params[:attachment_id])
    return render_error(message: "Attachment not found", status: :not_found) unless att

    att.purge
    render json: { message: "Attachment deleted" }, status: :ok
  end

  private

  def set_move_in
    @move_in = current_user.move_ins.find(params[:id])
  end

  def move_in_params
    params.require(:move_in).permit(
      :preferred_date, :preferred_time, :status,
      checklist: %i[
        submit_move_in_inspection_form
        collect_property_keys
        set_up_utilities
        review_property_rules
      ],
      attachments: []
    )
  end

  def scheduling_present?(record)
    record.preferred_date.present? || record.preferred_time.present?
  end

  def render_serialized(resource, action, status)
    render json: MoveInSerializer.new(
      resource,
      params: { action:, host: request.base_url }
    ).serializable_hash, status:
  end
end
