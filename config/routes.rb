# frozen_string_literal: true

Rails.application.routes.draw do
  resources :fridges do
    post :generate_recipe, on: :member
  end

  get 'barcodes/resolve', to: 'barcodes#resolve'

  get 'health_check', to: 'health_check#index'
  root 'fridges#new'
end
