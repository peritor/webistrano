ActionController::Routing::Routes.draw do |map|
  map.root :controller => "simple_example"
  map.connect ':controller/:action/:id'
end
