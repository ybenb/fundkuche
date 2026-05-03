# frozen_string_literal: true

class FridgesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_fridge, only: %i[show edit update destroy generate_recipe find_fooby_recipes]

  def index
    @fridges = Fridge.all
  end

  def show
    @fooby_recipes = @fridge.fooby_results
  end

  def new
    @fridge = Fridge.new(ingredients: [])
  end

  def results
    @fridge = Fridge.last
    @fooby_recipes = @fridge&.fooby_results || []
  end

  def edit; end

  def create
    @fridge = Fridge.new(fridge_params)

    if @fridge.save
      fetch_and_cache_recipes(@fridge)
      redirect_to fridge_url(@fridge), notice: 'Zutaten gespeichert.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    old_ingredients = @fridge.ingredients.map(&:attributes)
    if @fridge.update(fridge_params)
      if old_ingredients != @fridge.reload.ingredients.map(&:attributes)
        fetch_and_cache_recipes(@fridge)
      end
      redirect_to fridge_url(@fridge), notice: 'Kühlschrank aktualisiert.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @fridge.destroy
    redirect_to fridges_url, notice: 'Kühlschrank gelöscht.'
  end

  def generate_recipe
    RecipeSuggestionService.new(fridge: @fridge).call
    head :no_content
  end

  def find_fooby_recipes
    fetch_and_cache_recipes(@fridge)
    redirect_to fridge_path(@fridge), notice: 'Rezepte aktualisiert.'
  end

  private

  def set_fridge
    @fridge = Fridge.find(params[:id])
  end

  def fetch_and_cache_recipes(fridge)
    return if fridge.ingredients.empty?

    results = FoobyRecipeMatchService.new(fridge: fridge).call
    fridge.update_column(:fooby_results, results)
  end

  def fridge_params
    params.require(:fridge).permit(:recipe, ingredients_attributes: %i[name quantity _destroy])
  end
end
