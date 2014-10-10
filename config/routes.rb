Rails.application.routes.draw do
  resources :containers, :only => [:index, :new] do
    resources :steps, :controller => 'containers/steps', :only => [:show, :update]
  end
end
