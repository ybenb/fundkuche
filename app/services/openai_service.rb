# frozen_string_literal: true

class OpenaiService
  attr_reader :client

  def initialize
    @client = OpenAI::Client.new
  end

  def call(ingredients:)
    response = client.chat(parameters: chat_parameters(ingredients))
    response.dig('choices', 0, 'message', 'content')
  end

  private

  def chat_parameters(ingredients)
    {
      model: 'gpt-4',
      messages: [
        {
          role: 'system',
          content: 'You are a recipe generator that uses metric measurement units. Provide a simple recipe in plain text with only a dish name, prep time, and bullet-pointed steps using the given ingredients.' },
        {
          role: 'user',
          content: ingredients.join(', ')
        }
      ],
      temperature: 0.9
    }
  end
end
