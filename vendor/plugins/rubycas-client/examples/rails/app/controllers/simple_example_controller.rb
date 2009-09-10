# This is the most basic, bare-bones example.
# For advanced usage see the AdvancedExampleController.
class SimpleExampleController < ApplicationController
  # This will force CAS authentication before the user
  # is allowed to access any action in this controller. 
  before_filter CASClient::Frameworks::Rails::Filter

  def index
    @username = session[:cas_user]
  end

  def logout
    CASClient::Frameworks::Rails::Filter.logout(self)
  end

end
