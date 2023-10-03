# frozen_string_literal: true

class OpenaiService
  attr_reader :client

  def initialize
    @client = OpenAI::Client.new
  end

  def call(ingredients:)
    response = client.chat(parameters: {
                             model: 'gpt-4',
                             messages: [
                               { role: 'user', content: "I have the following ingredients: #{ingredients.join(', ')}. Can you suggest a recipe using them?" }
                             ],
                             temperature: 0.7
                           })

    response.dig('choices', 0, 'message', 'content')
  end
end
