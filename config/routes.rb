require 'saucy/routing_extensions'

Rails.application.routes.draw do
  resources :accounts, :only => [:index, :edit, :update, :destroy]

  through :accounts do
    resource  :billing
    resource  :plan
    resources :projects
    resources :memberships, :only => [:index, :edit, :update, :destroy]
    resources :invitations, :only => [:show, :update, :new, :create]
  end

  resources :plans, :only => [:index] do
    resources :accounts, :only => [:new, :create]
  end

  resource :profile, :only => [:edit, :update]
end
