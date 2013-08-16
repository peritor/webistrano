Www::Application.routes.draw do

  match '/' => 'projects#dashboard', :as => :home
  match ':controller/service.wsdl' => '#wsdl'

  resources :hosts
  resources :recipes do
    collection do
      get :preview
    end
  end

  resources :projects do
    member do
      get :dashboard
    end

    resources :project_configurations
    resources :stages do
      match :recipes, :on => :member
      member do
        get :capfile
        get :tasks
      end

      resources :stage_configurations
      resources :roles
      resources :deployments do
        collection do
          get :latest
        end

        member do
          post :cancel
        end
      end
    end
  end

  resources :users do

    member do
      get :deployments
      post :enable
    end

  end

  resources :sessions do
    collection do
      get :version
    end
  end

  match '/signup' => 'users#new', :as => :signup
  match '/login' => 'sessions#new', :as => :login
  match '/logout' => 'sessions#destroy', :as => :logout
  match '/stylesheets/application.css' => 'stylesheets#application', :as => :stylesheet
  match '/:controller(/:action(/:id))'
end