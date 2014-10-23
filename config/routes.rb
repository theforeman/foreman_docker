Rails.application.routes.draw do
  resources :containers, :only => [:index, :new, :show, :destroy] do
    member do
      post :commit
    end
    resources :steps, :controller => 'containers/steps', :only => [:show, :update]
    get :auto_complete_image, :on => :member
    get :auto_complete_image_tags, :on => :member
  end
end
