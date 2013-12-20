ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'rails/test_help'
require 'mocha/setup'
require File.expand_path(File.dirname(__FILE__) + "/factories")

class Test::Unit::TestCase
  include AuthenticatedTestHelper
  include Factories
  
  # disable transactional fixtures 
  self.use_transactional_fixtures = false
  
  # Instantiated fixtures
  self.use_instantiated_fixtures  = false
  
  def login(user=nil)
    user = user || create_new_user
    @request.session[:user] = user.id
    return user
  end
  
end
