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
    member do
      get :auto_complete_repository_name
      get :auto_complete_image_tag
      get :search_repository
    end
  end

  resources :registries, :except => [:show]

  scope :foreman_docker, :path => '/docker' do
    namespace :api, :defaults => { :format => 'json' } do
      scope "(:apiv)", :module => :v2, :defaults => { :apiv => 'v2' }, :apiv => /v2/,
                       :constraints => ApiConstraints.new(:version => 2) do
        resources :containers, :only => [:index, :create, :show, :destroy] do
          member do
            get :logs
            put :power
          end
        end
        resources :compute_resources, :only => [] do
          resources :containers, :only => [:index, :create, :show, :destroy] do
            member do
              get :logs
              put :power
            end
          end
        end
        resources :registries, :except => [:new, :edit]
      end
    end
  end
end
