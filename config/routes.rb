Rails.application.routes.draw do
  resources :containers, :only => [:index, :new, :show, :destroy] do
    member do
      post :commit
    end
    resources :steps, :controller => 'containers/steps', :only => [:show, :update]
    get :auto_complete_repository_name, :on => :member
    get :auto_complete_tag, :on => :member
    get :search_repository, :on => :member
  end
  resources :registries, :only => [:index, :new, :create, :update, :destroy, :edit]
end
