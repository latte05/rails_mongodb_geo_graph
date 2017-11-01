Rails.application.routes.draw do

  resources :pops do
    collection { post :import }
  end

  resources :sites
  resources :plans
  devise_for :users
  root "pages#home"

  resources :cats
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

end
