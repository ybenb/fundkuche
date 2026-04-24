# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

class BarcodeResolverService
  def initialize(barcode_number:)
    @barcode = barcode_number.to_s.strip
  end

  def call
    try_open_food_facts || try_goupc || raise("Produkt nicht gefunden für Barcode #{@barcode}")
  end

  private

  # Free, no API key required — covers most European EAN-13 barcodes
  def try_open_food_facts
    uri = URI("https://world.openfoodfacts.org/api/v0/product/#{@barcode}.json")
    response = get(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)

    body = JSON.parse(response.body)
    return nil unless body['status'] == 1

    product = body['product']
    # Prefer German name, fall back to generic name, then product_name
    name = product['product_name_de'].presence ||
           product['generic_name_de'].presence ||
           product['product_name'].presence ||
           product['generic_name'].presence
    name&.strip.presence
  rescue StandardError
    nil
  end

  # GoUPC fallback (requires API key in credentials.goupc.api_key or ENV GOUPC_API_KEY)
  def try_goupc
    api_key = ENV['GOUPC_API_KEY'] || Rails.application.credentials.goupc&.api_key
    return nil if api_key.blank?

    uri = URI("https://go-upc.com/api/v1/code/#{@barcode}")
    req = Net::HTTP::Get.new(uri)
    req['Authorization'] = "Bearer #{api_key}"
    req['Accept']        = 'application/json'

    response = get(uri, request: req)
    return nil unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body).dig('product', 'name')&.strip.presence
  rescue StandardError
    nil
  end

  def get(uri, request: Net::HTTP::Get.new(uri))
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https',
                                        open_timeout: 4, read_timeout: 6) do |http|
      http.request(request)
    end
  end
end
