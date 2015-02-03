Rails.application.routes.draw do
  resources :containers, :only => [:index, :new, :show, :destroy] do
    member do
      post :commit
      put :power
    end
  end

  resources :wizard_states, :only => [] do
    resources :steps, :controller => 'containers/steps', :only => [:show, :update]
  end

  resources :image_search, :only => [] do
    get :auto_complete_repository_name, :on => :member
    get :auto_complete_image_tag, :on => :member
    get :search_repository, :on => :member
  end

  resources :registries, :only => [:index, :new, :create, :update, :destroy, :edit]
end
