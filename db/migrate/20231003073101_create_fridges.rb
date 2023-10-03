# frozen_string_literal: true

class CreateFridges < ActiveRecord::Migration[7.0]
  def change
    create_table :fridges do |t|
      t.json :ingredients
      t.text :recipe

      t.timestamps
    end
  end
end
