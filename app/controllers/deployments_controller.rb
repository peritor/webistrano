class DeploymentsController < ApplicationController
  
  before_filter :load_stage
  before_filter :ensure_deployment_possible, :only => [:new, :create]

  # GET /projects/1/stages/1/deployments
  # GET /projects/1/stages/1/deployments.xml
  def index
    @deployments = @stage.deployments

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @deployments.to_xml }
    end
  end

  # GET /projects/1/stages/1/deployments/1
  # GET /projects/1/stages/1/deployments/1.xml
  def show
    @deployment = @stage.deployments.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @deployment.to_xml }
      format.js { render :partial => 'status.html.erb' }
    end
  end

  # GET /projects/1/stages/1/deployments/new
  def new
    @deployment = @stage.deployments.new
    @deployment.task = params[:task]
    
    if params[:repeat]
      @original = @stage.deployments.find(params[:repeat])
      @deployment = @original.repeat
    end
  end

  # POST /projects/1/stages/1/deployments
  # POST /projects/1/stages/1/deployments.xml
  def create
    @deployment = @stage.deployments.build(params[:deployment])
    @deployment.prompt_config = params[:deployment][:prompt_config] rescue {}    
    @deployment.user = current_user

    respond_to do |format|
      if @deployment.save
        
        @deployment.deploy_in_background!

        format.html { redirect_to project_stage_deployment_url(@project, @stage, @deployment)}
        format.xml  { head :created, :location => project_stage_deployment_url(@project, @stage, @deployment) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @deployment.errors.to_xml }
      end
    end
  end

  protected
  def ensure_deployment_possible
    if current_stage.deployment_possible?
        true
    else
      respond_to do |format|  
        flash[:notice] = 'A deployment is currently not possible.'
        format.html { redirect_to project_stage_url(@project, @stage) }
        format.xml  { render :xml => current_stage.deployment_errors.to_xml }
        false
      end
    end
  end
  
end
