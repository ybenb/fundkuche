# frozen_string_literal: true

class BarcodesController < ApplicationController
  def resolve
    product_name = BarcodeResolverService.new(barcode_number: params[:barcode_number]).call
    render json: { product_name: }, status: :ok
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
