# frozen_string_literal: true

class ImageService
  def call(image_path:)
    uri = URI.parse('https://api.ultralytics.com/v1/predict/R6nMlK6kQjSsQ76MPqQM')
    request = Net::HTTP::Post.new(uri)
    request.content_type = 'multipart/form-data'
    request['x-api-key'] = Rails.application.credentials.ultralytics.api_key!

    request.set_form([
                       ['size', '640'],
                       ['confidence', '0.05'],
                       ['iou', '0.05'],
                       ['image', File.open(resize_image(image_path))]
                     ], 'multipart/form-data')

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    response = http.request(request)
    response = JSON.parse(response.body)

    ingredients = response['data'].pluck('name')

    ingredients.each_with_object(Hash.new(0)) { |word, counts| counts[word] += 1 }
  end

  private

  def resize_image(image_path)
    image = MiniMagick::Image.open(image_path)
    image.resize '640x'
    Tempfile.new(['resized_image', '.jpg']).tap do |f|
      image.write f.path
    end.path
  end
end
