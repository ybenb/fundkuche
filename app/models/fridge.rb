# frozen_string_literal: true

class Fridge < ApplicationRecord
  include StoreModel::NestedAttributes

  attribute :ingredients, Ingredient.to_array_type
  accepts_nested_attributes_for :ingredients, allow_destroy: true

  def ingredients_text
    ingredients.map(&:name).join(', ')
  end
end
