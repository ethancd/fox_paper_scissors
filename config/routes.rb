Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'splash#index'

  get ':controller(/:action(/:slug))'

  match 'message', to: 'message#create', via: [:post]
  match 'play/move', to: 'play#move', via: [:post]
  match 'play/create', to: 'play#create', via: [:post]
  match 'play/offer-draw', to: 'play#offer_draw', via: [:post]
  match 'play/accept-draw', to: 'play#accept_draw', via: [:post]

  mount ActionCable.server => "/cable"
end
