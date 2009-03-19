ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.home '', :controller => "projects", :action => 'dashboard'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'
  
  map.resources :hosts
  map.resources :recipes, :collection => {:preview => :get}
  map.resources :projects, :member => {:dashboard => :get} do |projects|
    projects.resources :project_configurations
    
    projects.resources :stages, :member => {:capfile => :get, :recipes => :any, :tasks => :get} do |stages|
      stages.resources :stage_configurations
      stages.resources :roles
      stages.resources :deployments, :collection => {:latest => :get}, :member => {:cancel => :post}
    end
  end
  
  # RESTful auth
  map.resources :users,:member => {:deployments => :get, :enable => :post}
  map.resources :sessions, :collection => {:version => :get}
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login  '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  # stylesheet
  map.stylesheet '/stylesheets/application.css', :controller => 'stylesheets', :action => 'application'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
