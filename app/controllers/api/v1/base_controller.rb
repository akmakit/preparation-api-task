class Api::V1::BaseController < ActionController::API
  def not_found
    render json: "404", status: :not_found
  end
end
