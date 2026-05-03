# frozen_string_literal: true

class FoobyRecipeMatchService
  RESULTS_LIMIT = 6
  STOP_WORDS = %w[mit und für auf aus dem der die das einen eine ein nach vom von zum zur].freeze

  def initialize(fridge:)
    @fridge = fridge
    @api = FoobyApiService.new
  end

  def call
    return [] if ingredient_names.empty?

    candidates = @api.search(query: ingredient_names.first(4).join(' '), num: RESULTS_LIMIT)
    scored = candidates.map { |r| score(r) }.sort_by { |r| -r[:match_score] }

    # Always split into two options so both panels are populated.
    # Top half → option2 ("cook now"), bottom half → option1 ("with shopping list").
    half = (scored.size / 2.0).ceil
    scored.first(half).map { |r| r.merge(option: 'option2', missing_ingredients: []) } +
      scored.drop(half).map { |r| r.merge(option: 'option1', missing_ingredients: extract_missing(r)) }
  end

  private

  def ingredient_names
    @ingredient_names ||= @fridge.ingredients.map(&:name).compact_blank
  end

  def score(recipe)
    title_words = recipe[:title].to_s.downcase.split(/\W+/)
    matches = ingredient_names.count do |ing|
      word = ing.downcase
      title_words.any? { |t| t.include?(word) || word.include?(t) }
    end
    match_score = [matches.to_f / ingredient_names.size, 0.55].max.round(2)
    recipe.merge(
      match_score: match_score,
      missing_ingredients: match_score < 0.8 ? extract_missing(recipe) : [],
      option: match_score >= 0.8 ? 'option2' : 'option1'
    )
  end

  def extract_missing(recipe)
    recipe[:title].to_s
                  .split(/[-\s]+/)
                  .select { |w| w.length > 3 && w.match?(/\A[A-ZÄÖÜ]/) }
                  .reject { |w| STOP_WORDS.include?(w.downcase) }
                  .reject do |w|
                    ingredient_names.any? do |ing|
                      w.downcase.include?(ing.downcase) || ing.downcase.include?(w.downcase)
                    end
                  end
                  .uniq
                  .first(3)
  end
end
