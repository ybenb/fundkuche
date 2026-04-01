# frozen_string_literal: true

class ImageService
  ULTRALYTICS_URL = 'https://api.ultralytics.com/v1/predict/wW0GqcJuVhVIrAV9vpxQ'

  def initialize
    @client = OpenAI::Client.new
  end

  def call(image_path:)
    response = send_request(image_path)
    response = JSON.parse(response.body)

    ingredients = response['data'].pluck('name')

    ingredients = ingredients.each_with_object(Hash.new(0)) { |word, counts| counts[word] += 1 }
    ingredients = ingredients.select { |k, _v| ingredient?(k) }
    ingredients.map { |k, v| { name: k, quantity: v } }
  end

  private

  def ingredient?(ingredient)
    response = @client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [
          { role: 'user', content: "Is #{ingredient} edible or usable while cooking? only yes or no" }
        ],
        temperature: 0.7
      }
    )

    response = response.dig('choices', 0, 'message', 'content')
    response.downcase.include?('yes')
  end

  # rubocop:disable Metrics/AbcSize
  def send_request(image_path)
    uri = URI.parse(ULTRALYTICS_URL)
    request = Net::HTTP::Post.new(uri)
    request.content_type = 'multipart/form-data'
    request['x-api-key'] = ENV['ULTRALYTICS_API_KEY'] || Rails.application.credentials.ultralytics&.api_key

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
  # rubocop:enable Metrics/AbcSize

  def resize_image(image_path)
    image = MiniMagick::Image.open(image_path)
    image.resize '640x'
    Tempfile.new(['resized_image', '.jpg']).tap do |f|
      image.write f.path
    end.path
  end
end
