class ApplicationController < ActionController::Base
  include BrowserFilters
  include ExceptionNotifiable
  include AuthenticatedSystem
  
  before_filter :login_from_cookie, :login_required
  around_filter :set_timezone

  layout 'application'
  
  helper :all # include all helpers, all the time
  helper_method :current_stage, :current_project

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery
  
  protected
  
  def set_timezone
    # default timezone is UTC (Edinburgh)
    TzTime.zone = logged_in? ? ( current_user.tz rescue TimeZone['Edinburgh']): TimeZone['Edinburgh']
    yield
    TzTime.reset!
    TzTime.zone = TimeZone['Edinburgh']
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
  
end
