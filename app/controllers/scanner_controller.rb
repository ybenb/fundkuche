# frozen_string_literal: true

class ScannerController < ApplicationController
  before_action :authenticate_user!

  def create
    if params[:file].blank?
      render json: { error: 'File not provided' }, status: :bad_request
      return
    end

    unless OpenAI.configuration.access_token.present?
      Rails.logger.error '[ScannerController] OpenAI API key not configured (OPENAI_API_KEY env var missing)'
      render json: { error: 'OpenAI API key fehlt – bitte OPENAI_API_KEY als Umgebungsvariable setzen.' },
             status: :service_unavailable
      return
    end

    file = params[:file]
    ingredients = ImageService.new.call(image_data: file.read, content_type: file.content_type)
    render json: { ingredients: }
  rescue StandardError => e
    Rails.logger.error "[ScannerController] #{e.class}: #{e.message}"
    render json: { error: "Bilderkennung fehlgeschlagen: #{e.message.truncate(120)}" },
           status: :service_unavailable
  end
end
