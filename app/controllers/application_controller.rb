# ApplicationController
class ApplicationController < ActionController::Base
  # Run the block passed in, and assign its return value to object.
  # This method will fail loudly if not passed a block.
  #
  # status - The HTTP status code or symbol. The default value is :ok
  def render_or_error(status = :ok)
    object = yield

    if status == :found
      redirect_to object.full_url, status: status
    else
      render json: object, status: status
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: e.message }, status: :not_found
  rescue StandardError => e
    render json: { errors: e.message }, status: :bad_request
  end
end
