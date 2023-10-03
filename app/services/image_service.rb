# frozen_string_literal: true

class ImageService
  ULTRALYTICS_URL = 'https://api.ultralytics.com/v1/predict/R6nMlK6kQjSsQ76MPqQM'

  def call(image_path:)
    response = send_request(image_path)
    response = JSON.parse(response.body)

    ingredients = response['data'].pluck('name')

    ingredients.each_with_object(Hash.new(0)) { |word, counts| counts[word] += 1 }
  end

  private

  def send_request(image_path)
    uri = URI.parse(ULTRALYTICS_URL)
    request = Net::HTTP::Post.new(uri)
    request.content_type = 'multipart/form-data'
    request['x-api-key'] = Rails.application.credentials.ultralytics.api_key!

    params = [
      %w[size 640],
      %w[confidence 0.05],
      %w[iou 0.05],
      ['image', File.open(resize_image(image_path))]
    ]
    request.set_form(params, 'multipart/form-data')

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.request(request)
  end

  def resize_image(image_path)
    image = MiniMagick::Image.open(image_path)
    image.resize '640x'
    Tempfile.new(['resized_image', '.jpg']).tap do |f|
      image.write f.path
    end.path
  end
end
