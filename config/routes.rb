# frozen_string_literal: true

Rails.application.routes.draw do
  resources :fridges do
    post :generate_recipe, on: :member
  end

  post 'scanner/upload_image', to: 'scanner#create'
  get 'barcodes/resolve', to: 'barcodes#resolve'

  get 'health_check', to: 'health_check#index'
  get '/up', to: proc { [200, {}, ['ok']] }
  root 'fridges#new'
end
