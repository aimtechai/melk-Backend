class Api::V1::MaintenanceRequestsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_maintenance_request, only: %i[show update destroy update_status]

  def index
    @maintenance_requests = if current_user.has_role?(:tenant)
                              current_user.maintenance_requests
    else
                              MaintenanceRequest.all
    end

    serialized_requests = MaintenanceRequestSerializer.new(
      @maintenance_requests,
      params: { action: :index, host: request.base_url }
    ).serializable_hash

    render json: serialized_requests, status: :ok
  end

  def show
    serialized_request = MaintenanceRequestSerializer.new(
      @maintenance_request,
      params: { action: :show, host: request.base_url }
    ).serializable_hash

    render json: serialized_request, status: :ok
  end

  def create
    @maintenance_request = current_user.maintenance_requests.new(maintenance_request_params)

    if @maintenance_request.save
      serialized_request = MaintenanceRequestSerializer.new(
        @maintenance_request,
        params: { action: :create, host: request.base_url }
      ).serializable_hash
      render json: serialized_request, status: :created
    else
      render json: { errors: @maintenance_request.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @maintenance_request.update(maintenance_request_params)
      serialized_request = MaintenanceRequestSerializer.new(
        @maintenance_request,
        params: { action: :update, host: request.base_url }
      ).serializable_hash
      render json: serialized_request, status: :ok
    else
      render json: { errors: @maintenance_request.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @maintenance_request.destroy
      render json: { message: "Maintenance request deleted successfully." }, status: :ok
    else
      render json: { errors: @maintenance_request.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_status
    if @maintenance_request.update(status: params[:status])

      serialized_request = MaintenanceRequestSerializer.new(
        @maintenance_request,
        params: { action: :update_status, host: request.base_url }
      ).serializable_hash
      render json: serialized_request, status: :ok
    else
      render json: { errors: @maintenance_request.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_maintenance_request
    @maintenance_request = MaintenanceRequest.find(params[:id])
  end

  def maintenance_request_params
    params.require(:maintenance_request).permit(
      :title, :description, :location, :allow_entry, :status,
      :assigned_to_id,
      attachments: []
    )
  end
end
