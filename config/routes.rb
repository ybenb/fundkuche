# frozen_string_literal: true

Rails.application.routes.draw do
  resources :fridges
  get 'health_check', to: 'health_check#index'
  root 'pages#index'
end
