# frozen_string_literal: true

require 'net/http'
require 'uri'

class BarcodeResolverService
  attr_reader :uri

  def initialize(barcode_number:)
    @uri = URI.parse("https://go-upc.com/api/v1/code/#{barcode_number}")
  end

  def call
    request = Net::HTTP::Get.new(uri.request_uri)
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/json'
    request['Authorization'] = "Bearer #{ENV['GOUPC_API_KEY'] || Rails.application.credentials.goupc&.api_key}"

    response = perform_request(http_request: request)
    handle_response(response:)
  end

  private

  def perform_request(http_request:)
    request_options = { read_timeout: 5, open_timeout: 3, use_ssl: uri.scheme == 'https' }
    response = Net::HTTP.start(uri.host, uri.port, **request_options) do |http|
      http.request(http_request)
    end

    response.tap do |res|
      res.body = JSON.parse(res.body)
    end
  end

  def handle_response(response:)
    case response
    when Net::HTTPSuccess
      response.body['product']['name']
    else
      raise "Request failed with status #{response.code}"
    end
  end
end
