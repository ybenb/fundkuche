# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

class FoobyApiService
  BASE_URL = 'https://fooby.ch/hawaii_search.sri'
  IMAGE_BASE_URL = 'https://recipecontent.fooby.ch'

  def search(query:, num: 24, start: 0)
    uri = URI(BASE_URL)
    uri.query = URI.encode_www_form(
      query: query,
      lang: 'de',
      treffertyp: 'rezepte',
      start: start,
      num: num,
      interface: 'hawaii',
      userquery: true
    )

    response = Net::HTTP.get_response(uri)
    return [] unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    (data['results'] || []).map { |r| normalize(r) }
  rescue StandardError
    []
  end

  def featured_recipes
    search(query: 'Sommer', num: 8)
  end

  def image_url(keyvisual, width: 480, height: 320)
    "#{IMAGE_BASE_URL}/#{keyvisual}_3-2_#{width}-#{height}.jpg"
  end

  private

  def normalize(result)
    {
      id: result['recipe_id'],
      title: result['title'],
      url: result['url']&.start_with?('http') ? result['url'] : "https://fooby.ch#{result['url']}",
      image_url: image_url(result['keyvisual']),
      active_time: result['dauer_aktiv'],
      total_time: result['dauer_gesamt'],
      diet: result['ernaehrungsweise'],
      likes: result['likes']
    }
  end
end
