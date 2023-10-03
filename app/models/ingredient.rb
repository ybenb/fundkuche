# frozen_string_literal: true

class Ingredient
  include StoreModel::Model

  attribute :name, :string
  attribute :quantity, :string
end
