# frozen_string_literal: true

class ImageService
  SYSTEM_PROMPT = <<~PROMPT
    You are a kitchen ingredient detector. The user may show you:
    - A fridge or pantry photo with many ingredients
    - A single food item held in hand or placed on a surface
    - A product or vegetable/fruit close-up

    Identify ALL visible food items and ingredients, including single items held in hand.
    A person holding an orange, apple, or any fruit/vegetable should be detected.

    Return ONLY a valid JSON array — no markdown, no explanation, no code fences.
    Each element must have:
    - "name": ingredient name in German (e.g. "Orange", "Milch", "Karotten")
    - "quantity": estimated quantity as a string (e.g. "1 Stück", "1 Liter", "3")

    Example: [{"name":"Orange","quantity":"1 Stück"}]
    If nothing edible is visible, return: []
  PROMPT

  def initialize
    @client = OpenAI::Client.new
  end

  def call(image_path:)
    base64 = Base64.strict_encode64(File.binread(image_path))
    mime   = Marcel::MimeType.for(Pathname.new(image_path))

    response = @client.chat(
      parameters: {
        model: 'gpt-4o',
        messages: [
          { role: 'system', content: SYSTEM_PROMPT },
          {
            role: 'user',
            content: [
              { type: 'text', text: 'Identify all food ingredients visible in this photo, including any single items held in hand.' },
              { type: 'image_url', image_url: { url: "data:#{mime};base64,#{base64}", detail: 'high' } }
            ]
          }
        ],
        max_tokens: 500,
        temperature: 0.1
      }
    )

    raw = response.dig('choices', 0, 'message', 'content').to_s.strip
    # Strip markdown code fences if present
    raw = raw.gsub(/\A```(?:json)?\s*/i, '').gsub(/\s*```\z/, '').strip

    JSON.parse(raw).map { |i| { name: i['name'].to_s.strip, quantity: i['quantity'].to_s.strip } }
       .reject { |i| i[:name].blank? }
  rescue JSON::ParserError
    []
  end
end
