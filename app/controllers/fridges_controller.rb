# frozen_string_literal: true

class FridgesController < ApplicationController
  before_action :set_fridge, only: %i[show edit update destroy]

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

  private

  def set_fridge
    @fridge = Fridge.find(params[:id])
  end

  def fridge_params
    params.require(:fridge).permit(:recipe, ingredients_attributes: %i[name quantity _destroy])
  end
end
