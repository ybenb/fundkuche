# frozen_string_literal: true

class FoobyRecipeMatchJob < ApplicationJob
  queue_as :default

  def perform(fridge_id)
    fridge = Fridge.find_by(id: fridge_id)
    return unless fridge

    results = FoobyRecipeMatchService.new(fridge: fridge).call
    fridge.update(fooby_results: results)

    Turbo::StreamsChannel.broadcast_replace_to(
      [fridge, :stream],
      target: 'fridge_recipes',
      partial: 'fridges/recipe_results',
      locals: { fridge: fridge, fooby_recipes: results }
    )
  end
end
