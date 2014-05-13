#:nodoc:all
module Gms
  class ApplicationController < ActionController::Base
    #respond_to :json

    #rescue_from Exception, :with => :render_error
    rescue_from ActiveRecord::RecordNotFound, :with => :render_not_found
    rescue_from ActionController::RoutingError, :with => :render_not_found
    rescue_from ActionController::UnknownController, :with => :render_not_found

    private

    def render_not_found exception
      render json: {:error => "404"}, status: 404
    end

    def render_error exception
      # logger.info(exception) # for logging
      render json: {:error => "500"}, status: 500
    end
  end
end
