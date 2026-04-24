# frozen_string_literal: true

class PagesController < ApplicationController
  before_action :authenticate_user!, only: :fundkueche

  CATEGORIES = %w[Frühstück Hauptgericht Desserts Vegetarisch Vegan Backen Salate Suppen Schnell].freeze

  def index
    @query    = params[:q].to_s.strip
    @category = params[:category].to_s.strip
    @start    = params[:start].to_i.clamp(0, 500)
    @num      = 24

    search_term = @category.presence || @query.presence || 'Sommer'
    @recipes    = FoobyApiService.new.search(query: search_term, num: @num, start: @start)
    @has_more   = @recipes.size == @num

    respond_to do |format|
      format.html
      format.turbo_stream { render partial: 'pages/recipes_frame' }
    end
  end

  def fundkueche; end
end
