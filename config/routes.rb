Me::Application.routes.draw do
  match '*path', to: 'application#index', via: :get
  root 'application#index'
end
