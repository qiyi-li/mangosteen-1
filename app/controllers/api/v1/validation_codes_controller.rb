class Api::V1::ValidationCodesController < ApplicationController
  def create
    validation_code = ValidationCode.new email: params[:email], kind: "sign_in"
    if validation_code.save
      render json: { code: 0 }, status: 200
    else
      render json: { errors: validation_code.errors }, status: 422
    end
  end
end
