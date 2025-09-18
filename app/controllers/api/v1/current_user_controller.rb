class Api::V1::CurrentUserController < Api::V1::BaseController
  before_action :authenticate_user!

  def index
    render json: UserSerializer.new(current_user).serializable_hash[:data][:attributes], status: :ok
  end
end
