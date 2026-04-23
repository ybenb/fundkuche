# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  root 'pages#index'

  get 'fundkueche', to: 'pages#fundkueche', as: :fundkueche
  get 'fundkueche/scan', to: 'fridges#new', as: :fundkueche_scan
  get 'fundkueche/results', to: 'fridges#results', as: :fundkueche_results

  resources :fridges do
    post :generate_recipe, on: :member
    post :find_fooby_recipes, on: :member
  end

  post 'scanner/upload_image', to: 'scanner#create'
  get 'barcodes/resolve', to: 'barcodes#resolve'

  get 'health_check', to: 'health_check#index'
  get '/up', to: proc { [200, {}, ['ok']] }
end
