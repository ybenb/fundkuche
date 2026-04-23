# frozen_string_literal: true

class PagesController < ApplicationController
  def index
    @featured_recipes = FoobyApiService.new.featured_recipes
  end

  def fundkueche; end
end
