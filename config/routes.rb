Rails.application.routes.draw do
  resources :containers, :only => [:index, :new, :show] do
    resources :steps, :controller => 'containers/steps'
  end
end
