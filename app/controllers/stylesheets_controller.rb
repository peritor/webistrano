class StylesheetsController < ApplicationController
  
  skip_before_filter :login_required
  if WebistranoConfig[:authentication_method] == :cas
    skip_before_filter CASClient::Frameworks::Rails::Filter
  end
  
  caches_page :application
  
  def application
    render :content_type => 'text/css', :layout => false
  end
  
end
