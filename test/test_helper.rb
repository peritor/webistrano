ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'mocha'
require File.expand_path(File.dirname(__FILE__) + "/factories")

class ActiveSupport::TestCase
  include AuthenticatedTestHelper
  include Factories
  
  # Transactional fixtures 
  self.use_transactional_fixtures = true

  # Instantiated fixtures
  self.use_instantiated_fixtures  = false

  # Add more helper methods to be used by all tests here...
  
  def prepare_email
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    return ActionMailer::Base.deliveries
  end
  
  def login(user=nil)
    user = user || create_new_user
    @request.session[:user] = user.id
    return user
  end
  
  def admin_login
    admin = login
    admin.make_admin!
    return admin
  end
    
  
end
