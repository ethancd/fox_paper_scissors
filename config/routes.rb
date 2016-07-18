Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'splash#index'

  get ':controller(/:action(/:slug))'

  match 'message', to: 'message#create', via: [:post]
  match 'play/move', to: 'play#move', via: [:post]
  match 'play/create', to: 'play#create', via: [:post]

  mount ActionCable.server => "/cable"
end
