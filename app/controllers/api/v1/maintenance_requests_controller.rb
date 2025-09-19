class Api::V1::MaintenanceRequestsController < Api::V1::BaseController
  before_action :set_maintenance_request, only: %i[show update destroy update_status]

  # GET /api/v1/maintenance_requests
  def index
    requests = current_user.has_role?(:tenant) ? current_user.maintenance_requests : MaintenanceRequest.all
    render_serialized(requests, :index, :ok)
  end

  # GET /api/v1/maintenance_requests/:id
  def show
    render_serialized(@maintenance_request, :show, :ok)
  end

  # POST /api/v1/maintenance_requests
  def create
    request = current_user.maintenance_requests.new(maintenance_request_params)
    if request.save
      render_serialized(request, :create, :created)
    else
      render_error(
        message: "Failed to create maintenance request",
        status: :unprocessable_entity,
        details: request.errors.full_messages
      )
    end
  end

  # PATCH/PUT /api/v1/maintenance_requests/:id
  def update
    if @maintenance_request.update(maintenance_request_params)
      render_serialized(@maintenance_request, :update, :ok)
    else
      render_error(
        message: "Failed to update maintenance request",
        status: :unprocessable_entity,
        details: @maintenance_request.errors.full_messages
      )
    end
  end

  # DELETE /api/v1/maintenance_requests/:id
  def destroy
    if @maintenance_request.destroy
      render json: { message: "Maintenance request deleted successfully" }, status: :ok
    else
      render_error(
        message: "Failed to delete maintenance request",
        status: :unprocessable_entity,
        details: @maintenance_request.errors.full_messages
      )
    end
  end

  # PATCH /api/v1/maintenance_requests/:id/update_status
  def update_status
    if @maintenance_request.update(status: params[:status])
      render_serialized(@maintenance_request, :update_status, :ok)
    else
      render_error(
        message: "Failed to update status",
        status: :unprocessable_entity,
        details: @maintenance_request.errors.full_messages
      )
    end
  end

  private

  def set_maintenance_request
    @maintenance_request = MaintenanceRequest.find(params[:id])
  end

  def maintenance_request_params
    params.require(:maintenance_request).permit(
      :title, :description, :location, :allow_entry, :status, :assigned_to_id,
      attachments: []
    )
  end

  def render_serialized(resource, action, status)
    render json: MaintenanceRequestSerializer.new(
      resource,
      params: { action:, host: request.base_url }
    ).serializable_hash,
           status: status
  end
end
