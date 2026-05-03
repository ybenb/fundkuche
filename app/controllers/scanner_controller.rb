# frozen_string_literal: true

class ScannerController < ApplicationController
  before_action :authenticate_user!

  def create
    if params[:file].blank?
      render json: { error: 'File not provided' }, status: :bad_request
      return
    end

    file = params[:file]
    ingredients = ImageService.new.call(image_data: file.read, content_type: file.content_type)
    render json: { ingredients: }
  rescue StandardError => e
    Rails.logger.error "[ScannerController] #{e.class}: #{e.message}"
    render json: { error: 'Bilderkennung nicht verfügbar. Bitte überprüfe die OpenAI API-Konfiguration.' },
           status: :service_unavailable
  end
end
