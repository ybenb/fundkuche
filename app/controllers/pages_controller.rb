# frozen_string_literal: true

class PagesController < ApplicationController
  before_action :authenticate_user!, only: :fundkueche

  def index
    @featured_recipes = FoobyApiService.new.featured_recipes
  end

  def fundkueche; end
end
