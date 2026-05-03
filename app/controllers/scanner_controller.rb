# frozen_string_literal: true

class ScannerController < ApplicationController
  def create
    if params[:file].blank?
      render json: { error: 'File not provided' }, status: :bad_request
      return
    end

    file = params[:file]
    render json: { ingredients: ImageService.new.call(image_data: file.read, content_type: file.content_type) }
  end
end
