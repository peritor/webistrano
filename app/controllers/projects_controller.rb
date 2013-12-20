class ProjectsController < ApplicationController
  
  before_filter :load_templates, :only => [:new, :create, :edit, :update]
  before_filter :load_project, :only => [:show, :destroy, :edit, :update]
  before_filter :ensure_can_access_project, :except => [:new, :create, :dashboard, :index]
  before_filter :ensure_can_edit_project, :only => [:edit, :update]
  before_filter :ensure_can_manage_projects, :only => [:new, :create, :destroy]
  
  # GET /projects/dashboard
  def dashboard
    @deployments = Deployment.find(:all,
                                   :include    => {:stage => :project},
                                   :conditions => {'stages.project_id' => @sidebar_projects},
                                   :order      => 'deployments.created_at DESC',
                                   :limit      => 3)

    respond_to do |format|
      format.html # dashboard.rhtml
    end
  end
  
  # GET /projects
  # GET /projects.xml
  def index
    @projects = Project.active.select { |p| 
      ensure_can_access_project(p)
    }
    
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @projects.to_xml }
    end
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    @can_edit_project = current_user.can_edit?(@project)

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @project.to_xml }
    end
  end

  # GET /projects/new
  def new
    @project = Project.new
    if load_clone_original
      @project.prepare_cloning(@original)
      render :action => 'clone' and return
    end
  end

  # GET /projects/1;edit
  def edit
  end

  # POST /projects
  # POST /projects.xml
  def create
    @project = Project.new(params[:project])
    
    if load_clone_original
      action_to_render = 'clone'  
    else
      action_to_render = 'new'  
    end
    
    @project.user_ids = params[:project][:user_ids] || []
      
    respond_to do |format|
      if @project.save
        @project.clone(@original) if load_clone_original
        
        flash[:notice] = 'Project was successfully created.'
        format.html { redirect_to project_url(@project) }
        format.xml  { head :created, :location => project_url(@project) }
      else
        format.html { render :action => action_to_render }
        format.xml  { render :xml => @project.errors.to_xml }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    @project.user_ids = params[:project][:user_ids] || []

    respond_to do |format|
      if @project.update_attributes(params[:project])
        flash[:notice] = 'Project was successfully updated.'
        format.html { redirect_to(@project.archived? ? projects_path : project_url(@project))}
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
    @project.destroy

    respond_to do |format|
      flash[:notice] = 'Project was successfully deleted.'
      format.html { redirect_to projects_url }
      format.xml  { head :ok }
    end
  end
  
  protected
  def load_templates
    @templates = ProjectConfiguration.templates.sort.collect do |k,v|
      [k.to_s.titleize, k.to_s]
    end  
    
    @template_infos = ProjectConfiguration.templates.collect do |k,v|
      [k.to_s, v::DESC]
    end
  end
  
  def load_clone_original
    if params[:clone]
      @original = Project.active.find(params[:clone])
    else
      false
    end
  end
end
