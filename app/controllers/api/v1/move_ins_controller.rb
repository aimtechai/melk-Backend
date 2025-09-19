# app/controllers/api/v1/move_ins_controller.rb
class Api::V1::MoveInsController < Api::V1::BaseController
  before_action :set_move_in, only: %i[show update destroy update_status update_checklist schedule attachments destroy_attachment]

  # CRUD (generic)
  def index
    records = current_user.has_role?(:tenant) ? current_user.move_ins : MoveIn.all
    render_serialized(records, :index, :ok)
  end

  def show
    render_serialized(@move_in, :show, :ok)
  end

  def create
    record = current_user.move_ins.new(move_in_params)

    # Don’t allow scheduling fields unless checklist is already complete
    if scheduling_present?(record) && !record.checklist_complete?
      return render_error(message: "Complete all checklist items before scheduling", status: :unprocessable_entity)
    end

    if record.save
      render_serialized(record, :create, :created)
    else
      render_error(message: "Failed to create move-in", status: :unprocessable_entity, details: record.errors.full_messages)
    end
  end

  def update
    # Same guard for scheduling on generic update
    if scheduling_params_present? && !@move_in.checklist_complete?
      return render_error(message: "Complete all checklist items before scheduling", status: :unprocessable_entity)
    end

    if @move_in.update(move_in_params)
      render_serialized(@move_in, :update, :ok)
    else
      render_error(message: "Failed to update move-in", status: :unprocessable_entity, details: @move_in.errors.full_messages)
    end
  end

  def destroy
    if @move_in.destroy
      render json: { message: "Move-in deleted successfully" }, status: :ok
    else
      render_error(message: "Failed to delete move-in", status: :unprocessable_entity, details: @move_in.errors.full_messages)
    end
  end

  # Step 1 — Checklist
  def update_checklist
    if @move_in.update(checklist_params)
      render_serialized(@move_in, :update_checklist, :ok)
    else
      render_error(message: "Failed to update checklist", status: :unprocessable_entity, details: @move_in.errors.full_messages)
    end
  end

  # Step 2 — Schedule (requires checklist complete)
  def schedule
    unless @move_in.checklist_complete?
      return render_error(message: "Complete all checklist items before scheduling", status: :unprocessable_entity)
    end

    if @move_in.update(schedule_params)
      render_serialized(@move_in, :schedule, :ok)
    else
      render_error(message: "Failed to schedule walkthrough", status: :unprocessable_entity, details: @move_in.errors.full_messages)
    end
  end

  # Step 3 — Upload attachments (append; respects 500MB/file in model)
  def attachments
    files = attachments_params[:attachments]
    return render_error(message: "No files attached", status: :bad_request) if files.blank?

    files.each { |f| @move_in.attachments.attach(f) }
    if @move_in.errors.any?
      render_error(message: "Failed to attach files", status: :unprocessable_entity, details: @move_in.errors.full_messages)
    else
      render_serialized(@move_in, :attachments, :ok)
    end
  end

  def destroy_attachment
    att = @move_in.attachments.find_by(id: params[:attachment_id])
    return render_error(message: "Attachment not found", status: :not_found) unless att

    att.purge
    render json: { message: "Attachment deleted" }, status: :ok
  end

  # Status (manager/owner)
  def update_status
    unless MoveIn.statuses.keys.include?(params[:status].to_s)
      return render_error(message: "Invalid status", status: :bad_request)
    end

    if @move_in.update(status: params[:status])
      render_serialized(@move_in, :update_status, :ok)
    else
      render_error(message: "Failed to update status", status: :unprocessable_entity, details: @move_in.errors.full_messages)
    end
  end

  private

  def set_move_in
    @move_in = MoveIn.find(params[:id])
  end

  # Generic create/update
  def move_in_params
    params.require(:move_in).permit(
      :preferred_date, :preferred_time, :status,  # status usually staff-only
      checklist: %i[
        submit_move_in_inspection_form
        collect_property_keys
        set_up_utilities
        review_property_rules
      ],
      attachments: [] # only used for create if you choose; step endpoint preferred
    )
  end

  # Step-specific strong params
  def checklist_params
    params.require(:move_in).permit(checklist: %i[
      submit_move_in_inspection_form
      collect_property_keys
      set_up_utilities
      review_property_rules
    ])
  end

  def schedule_params
    params.require(:move_in).permit(:preferred_date, :preferred_time)
  end

  def attachments_params
    params.require(:move_in).permit(attachments: [])
  end

  # Helpers
  def scheduling_present?(record)
    record.preferred_date.present? || record.preferred_time.present?
  end

  def scheduling_params_present?
    params.dig(:move_in, :preferred_date).present? || params.dig(:move_in, :preferred_time).present?
  end

  # Standard renderer
  def render_serialized(resource, action, status)
    render json: MoveInSerializer.new(
      resource,
      params: { action:, host: request.base_url }
    ).serializable_hash, status:
  end
end
