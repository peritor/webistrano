class StylesheetsController < ApplicationController
  
  skip_before_filter :login_required
  
  session :off
  
  caches_page :application
  
  def application
    render :content_type => 'text/css', :layout => false
  end
  
end
