# frozen_string_literal: false

class RecipeSuggestionService
  attr_reader :client, :fridge

  def initialize(fridge:)
    @client = OpenAI::Client.new
    @fridge = fridge
  end

  def call
    response_content = ''

    client.chat(
      parameters: {
        model: 'gpt-4',
        messages: [
          { role: 'system', content: 'You are a recipe generator that uses metric measurement units. Provide a simple recipe in plain text with only a dish name, prep time, and bullet-pointed steps using the given ingredients.' }, # rubocop:disable Layout/LineLength
          { role: 'user', content: user_message_content }
        ],
        temperature: 0.8,
        stream: stream_proc(response_content:)
      }
    )

    fridge.update!(recipe: response_content)
  end

  private

  def user_message_content
    fridge.ingredients.map { |i| [i.quantity, i.name].compact.join(' ') }.join(', ')
  end

  def stream_proc(response_content:)
    proc do |chunk, _bytesize|
      new_content = chunk.dig('choices', 0, 'delta', 'content').to_s
      response_content << new_content
      fridge.broadcast_recipe_update(response_content)
    end
  end
end
