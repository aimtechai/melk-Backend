class Api::V1::MaintenanceRequestsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_maintenance_request, only: %i[show update destroy update_status]

  # GET /api/v1/maintenance_requests
  def index
    # Tenants only see their own requests, managers/owners see all
    @maintenance_requests = if current_user.has_role?(:tenant)
                              current_user.maintenance_requests
    else
                              MaintenanceRequest.all
    end

    render json: @maintenance_requests, each_serializer: MaintenanceRequestSerializer
  end

  # GET /api/v1/maintenance_requests/:id
  def show
    render json: @maintenance_request, serializer: MaintenanceRequestSerializer
  end

  # POST /api/v1/maintenance_requests
  def create
    Rails.logger.info "Params received: #{params.inspect}"
    @maintenance_request = current_user.maintenance_requests.new(maintenance_request_params)

    if @maintenance_request.save
      render json: MaintenanceRequestSerializer.new(@maintenance_request).serializable_hash, status: :created

      # render json: @maintenance_request, serializer: MaintenanceRequestSerializer, status: :created
    else
      render json: { errors: @maintenance_request.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/maintenance_requests/:id
  def update
    if @maintenance_request.update(maintenance_request_params)
      render json: @maintenance_request, serializer: MaintenanceRequestSerializer
    else
      render json: { errors: @maintenance_request.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/maintenance_requests/:id
  def destroy
    @maintenance_request.destroy
    head :no_content
  end

  # PATCH /api/v1/maintenance_requests/:id/update_status
  def update_status
    if @maintenance_request.update(status: params[:status])
      render json: { message: "Status updated", request: MaintenanceRequestSerializer.new(@maintenance_request) }
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
