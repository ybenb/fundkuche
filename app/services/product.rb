# frozen_string_literal: true

class Product
  include ActiveModel::Model

  # attr_accessor :code, :code_type, :name, :description, :image_url, :brand, :specs
  attr_accessor :name
end
