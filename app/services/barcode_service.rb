# frozen_string_literal: true

require 'net/http'
require 'uri'

class BarcodeService
  def self.fetch_product(barcode_number)
    url = URI.parse("https://go-upc.com/api/v1/code/#{barcode_number}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true if url.scheme == 'https'

    request = Net::HTTP::Get.new(url.path, {
                                   'Authorization' => "Bearer #{Rails.application.credentials.dig(:goupc, :api_key)}"
                                 })

    response = http.request(request)

    return unless response.code == '200'

    json = JSON.parse(response.body, symbolize_names: true)
    Product.new(name: json[:product][:name])
  end
end
