# frozen_string_literal: true

class FridgesController < ApplicationController
  before_action :set_fridge, only: %i[show edit update destroy generate_recipe]

  def index
    @fridges = Fridge.all
  end

  def show; end

  def new
    @fridge = Fridge.new(ingredients: [Ingredient.new, Ingredient.new, Ingredient.new])
  end

  def edit; end

  def create
    @fridge = Fridge.new(fridge_params)

    if @fridge.save
      redirect_to fridge_url(@fridge), notice: 'Fridge was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @fridge.update(fridge_params)
      redirect_to fridge_url(@fridge), notice: 'Fridge was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @fridge.destroy

    redirect_to fridges_url, notice: 'Fridge was successfully destroyed.'
  end

  def generate_recipe
    RecipeSuggestionService.new(fridge: @fridge).call # would be better to use a background job here :)
    head :no_content
  end

  private

  def set_fridge
    @fridge = Fridge.find(params[:id])
  end

  def fridge_params
    params.require(:fridge).permit(:recipe, ingredients_attributes: %i[name quantity _destroy])
  end
end
