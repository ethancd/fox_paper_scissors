Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'splash#index'

  get ':controller(/:action(/:id))'

  match 'chat', to: 'chat#respond', via: [:post]
  match 'play/move', to: 'play#send_move', via: [:post]
end
