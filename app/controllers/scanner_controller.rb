# frozen_string_literal: true

class ScannerController < ApplicationController
  def create
    if params[:file].blank?
      render json: { error: 'File not provided' }, status: :bad_request
      return
    end

    uploaded_file_path = params[:file].tempfile.path
    render json: { ingredients: ImageService.new.call(image_path: uploaded_file_path) }
  end
end
