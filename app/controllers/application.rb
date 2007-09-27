class ApplicationController < ActionController::Base
  include BrowserFilters
  include ExceptionNotifiable
  include AuthenticatedSystem
  
  before_filter :login_from_cookie, :login_required
  
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_webistrano_session_id'
  
  layout 'application'
  
  helper_method :current_stage, :current_project
  
  protected
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
  
end
