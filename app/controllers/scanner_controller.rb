# frozen_string_literal: true

class ScannerController < ApplicationController
  before_action :authenticate_user!

  def create
    if params[:file].blank?
      render json: { error: 'File not provided' }, status: :bad_request
      return
    end

    uploaded_file_path = params[:file].tempfile.path
    ingredients = ImageService.new.call(image_path: uploaded_file_path)
    render json: { ingredients: }
  rescue StandardError => e
    Rails.logger.error "[ScannerController] #{e.class}: #{e.message}"
    render json: { error: 'Bilderkennung nicht verfügbar. Bitte überprüfe die OpenAI API-Konfiguration.' },
           status: :service_unavailable
  end
end
