# frozen_string_literal: true

class FoobyRecipeMatchService
  MATCH_THRESHOLD = 0.8

  def initialize(fridge:)
    @fridge = fridge
    @api = FoobyApiService.new
    @openai = OpenAI::Client.new
  end

  def call
    return [] if ingredient_names.empty?

    candidates = @api.search(query: ingredient_names.first(4).join(' '), num: 12)
    return [] if candidates.empty?

    candidates.map { |recipe| enrich_with_match(recipe) }
              .select { |r| r[:match_score] >= MATCH_THRESHOLD }
              .sort_by { |r| -r[:match_score] }
              .first(6)
  end

  private

  def ingredient_names
    @ingredient_names ||= @fridge.ingredients.map(&:name).reject(&:blank?)
  end

  def enrich_with_match(recipe)
    analysis = gpt_match_analysis(recipe[:title])
    recipe.merge(
      match_score: analysis[:score],
      missing_ingredients: analysis[:missing],
      alternatives: analysis[:alternatives],
      option: analysis[:score] >= MATCH_THRESHOLD ? :option2 : :option1
    )
  end

  def gpt_match_analysis(recipe_title)
    prompt = <<~PROMPT
      Kühlschrank-Zutaten: #{ingredient_names.join(', ')}

      Rezept: "#{recipe_title}"

      Analysiere kurz:
      1. Welche Zutaten fehlen typischerweise für dieses Rezept?
      2. Welcher Prozentsatz (0.0 bis 1.0) der Zutaten ist vorhanden?
      3. Schlage kurze Alternativen für fehlende Zutaten vor.

      Antworte NUR als JSON: {"score": 0.85, "missing": ["Sahne", "Knoblauch"], "alternatives": {"Sahne": "Joghurt", "Knoblauch": "Knoblauchpulver"}}
    PROMPT

    response = @openai.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.3,
        max_tokens: 200
      }
    )

    content = response.dig('choices', 0, 'message', 'content').to_s
    json = JSON.parse(content)
    { score: json['score'].to_f, missing: json['missing'] || [], alternatives: json['alternatives'] || {} }
  rescue StandardError
    { score: 0.5, missing: [], alternatives: {} }
  end
end
