# frozen_string_literal: true

class Fridge < ApplicationRecord
  include StoreModel::NestedAttributes

  attribute :ingredients, Ingredient.to_array_type
  accepts_nested_attributes_for :ingredients, allow_destroy: true
  before_save :remove_empty_ingredients

  def broadcast_recipe_update(content)
    self.recipe = content

    broadcast_replace_to(
      [self, :stream],
      partial: 'fridges/fridge',
      locals: { fridge: self },
      target: self
    )
  end

  def ingredients_text
    ingredients.map(&:name).join(', ')
  end

  def remove_empty_ingredients
    ingredients.each do |ingredient|
      ingredients.delete(ingredient) if ingredient.name.blank?
    end
  end
end
