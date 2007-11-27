class ProjectsController < ApplicationController
  
  before_filter :load_templates, :only => [:new, :create, :edit, :update]
  before_filter :ensure_admin, :only => [:new, :edit, :destroy, :create, :update]
  
  # GET /projects/dashboard
  def dashboard
    @user_deployments = current_user.recent_deployments(3)
    @deployments = Deployment.find(:all, :limit => 3, :order => 'created_at DESC')

    respond_to do |format|
      format.html # dashboard.rhtml
    end
  end
  
  # GET /projects
  # GET /projects.xml
  def index
    @projects = Project.find(:all, :order => 'name ASC')

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @projects.to_xml }
    end
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    @project = Project.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @project.to_xml }
    end
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1;edit
  def edit
    @project = Project.find(params[:id])
  end

  # POST /projects
  # POST /projects.xml
  def create
    @project = Project.new(params[:project])

    respond_to do |format|
      if @project.save
        flash[:notice] = 'Project was successfully created.'
        format.html { redirect_to project_url(@project) }
        format.xml  { head :created, :location => project_url(@project) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @project.errors.to_xml }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    @project = Project.find(params[:id])

    respond_to do |format|
      if @project.update_attributes(params[:project])
        flash[:notice] = 'Project was successfully updated.'
        format.html { redirect_to project_url(@project) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @project.errors.to_xml }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      flash[:notice] = 'Project was successfully deleted.'
      format.html { redirect_to projects_url }
      format.xml  { head :ok }
    end
  end
  
  protected
  def load_templates
    @templates = ProjectConfiguration.templates.collect do |k,v|
      [k.to_s.titleize, k.to_s]
    end  
    
    @template_infos = ProjectConfiguration.templates.collect do |k,v|
      [k.to_s, v::DESC]
    end
  end
end
