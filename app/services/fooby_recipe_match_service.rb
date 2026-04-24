# frozen_string_literal: true

class FoobyRecipeMatchService
  MATCH_THRESHOLD = 0.5

  def initialize(fridge:)
    @fridge = fridge
    @api = FoobyApiService.new
    @openai = OpenAI::Client.new
  end

  def call
    return [] if ingredient_names.empty?

    candidates = @api.search(query: ingredient_names.first(4).join(' '), num: 12)
    return [] if candidates.empty?

    batch_analyze(candidates)
  end

  private

  def ingredient_names
    @ingredient_names ||= @fridge.ingredients.map(&:name).reject(&:blank?)
  end

  def batch_analyze(candidates)
    titles = candidates.map.with_index(1) { |r, i| "#{i}. #{r[:title]}" }.join("\n")

    prompt = <<~PROMPT
      Kühlschrank-Zutaten: #{ingredient_names.join(', ')}

      Analysiere diese #{candidates.size} Rezepte und wie gut sie zu den Zutaten passen.
      #{titles}

      Antworte NUR als JSON-Array (kein Markdown, keine Erklärung):
      [{"index":1,"score":0.85,"missing":["Sahne","Knoblauch"]},...]

      score: 0.0-1.0 (Anteil der vorhandenen Zutaten)
      missing: Liste der fehlenden Hauptzutaten (max. 4)
    PROMPT

    response = @openai.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.2,
        max_tokens: 800
      }
    )

    raw = response.dig('choices', 0, 'message', 'content').to_s.strip
    raw = raw.gsub(/\A```(?:json)?\s*/i, '').gsub(/\s*```\z/, '').strip
    analyses = JSON.parse(raw)

    results = candidates.map.with_index(1) do |recipe, i|
      a = analyses.find { |x| x['index'] == i } || { 'score' => 0.5, 'missing' => [] }
      score = a['score'].to_f
      recipe.merge(
        match_score: score,
        missing_ingredients: (a['missing'] || []).compact,
        option: score >= 0.8 ? 'option2' : 'option1'
      )
    end

    results.select { |r| r[:match_score] >= MATCH_THRESHOLD }
           .sort_by { |r| -r[:match_score] }
           .first(6)
  rescue StandardError => e
    Rails.logger.error("FoobyRecipeMatchService error: #{e.message}")
    []
  end
end
