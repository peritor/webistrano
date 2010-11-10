class ApplicationController < ActionController::Base
  include BrowserFilters
  include ExceptionNotifiable
  include AuthenticatedSystem
  
  before_filter CASClient::Frameworks::Rails::Filter if WebistranoConfig[:authentication_method] == :cas
  before_filter :login_from_cookie, :login_required, :ensure_not_disabled
  around_filter :set_timezone

  layout 'application'
  
  helper :all # include all helpers, all the time
  helper_method :current_stage, :current_project

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery
  
  protected
  
  def set_timezone
    # default timezone is UTC
    Time.zone = logged_in? ? ( current_user.time_zone rescue 'UTC'): 'UTC'
    yield
    Time.zone = 'UTC'
  end
  
  def load_project
    @project = Project.find(params[:project_id])
  end
  
  def load_stage
    load_project
    @stage = @project.stages.find(params[:stage_id])
  end
  
  def current_stage
    @stage
  end
  
  def current_project
    @project
  end
  
  def ensure_admin
    if logged_in? && current_user.admin?
      return true
    else
      flash[:notice] = "Action not allowed"
      redirect_to home_path
      return false
    end
  end
  
  def ensure_can_access_project(project=nil)
    project ||= @project
    current_user.admin? || current_user.can_manage_projects? || current_user.projects.include?(project)
  end
  
  def ensure_can_manage_projects
    current_user.can_manage_projects?
  end
  
  def ensure_can_edit_project
    current_user.can_edit?(@project)
  end
  
  def ensure_can_manage_hosts
    current_user.can_manage_hosts?
  end
  
  def ensure_can_manage_recipes
    current_user.can_manage_recipes?
  end
  
  def ensure_not_disabled
    if logged_in? && current_user.disabled?
      logout
      return false
    else
      return true
    end
  end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    if WebistranoConfig[:authentication_method] != :cas
      flash[:notice] = "You have been logged out."
      redirect_back_or_default( home_path )
    else
      redirect_to "#{CASClient::Frameworks::Rails::Filter.config[:logout_url]}?serviceUrl=#{home_url}"
    end
  end
  
end
