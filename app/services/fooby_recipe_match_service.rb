# frozen_string_literal: true

class FoobyRecipeMatchService
  RESULTS_LIMIT = 6

  def initialize(fridge:)
    @fridge = fridge
    @api = FoobyApiService.new
  end

  def call
    return [] if ingredient_names.empty?

    candidates = @api.search(query: ingredient_names.first(4).join(' '), num: RESULTS_LIMIT)
    candidates.map { |r| score(r) }
              .sort_by { |r| -r[:match_score] }
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
      missing_ingredients: [],
      option: match_score >= 0.8 ? 'option2' : 'option1'
    )
  end
end
