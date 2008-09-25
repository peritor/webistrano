class StagesController < ApplicationController

  before_filter :load_project
  
  # GET /projects/1/stages.xml
  def index
    @stages = current_project.stages
    respond_to do |format|
      format.xml  { render :xml => @stages.to_xml }
    end
  end

  # GET /projects/1/stages/1
  # GET /projects/1/stages/1.xml
  def show
    @stage = current_project.stages.find(params[:id])
    @task_list = [['All tasks: ', '']] + @stage.list_tasks.collect{|task| [task[:name], task[:name]]}.sort()

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @stage.to_xml }
    end
  end

  # GET /projects/1/stages/new
  def new
    @stage = current_project.stages.new
  end

  # GET /projects/1/stages/1;edit
  def edit
    @stage = current_project.stages.find(params[:id])
  end
  
  # GET /projects/1/stages/1/tasks
  # GET /projects/1/stages/1/tasks.xml
  def tasks
    @stage = current_project.stages.find(params[:id])
    @tasks = @stage.list_tasks
    
    respond_to do |format|
      format.html # tasks.rhtml
      format.xml  { render :xml => @tasks.to_xml }
    end
  end

  # POST /projects/1/stages
  # POST /projects/1/stages.xml
  def create
    @stage = current_project.stages.build(params[:stage])

    respond_to do |format|
      if @stage.save
        flash[:notice] = 'Stage was successfully created.'
        format.html { redirect_to project_stage_url(current_project, @stage) }
        format.xml  { head :created, :location => project_stage_url(current_project, @stage) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @stage.errors.to_xml }
      end
    end
  end

  # PUT /projects/1/stages/1
  # PUT /projects/1/stages/1.xml
  def update
    @stage = current_project.stages.find(params[:id])
    
    respond_to do |format|
      if @stage.update_attributes(params[:stage])
        flash[:notice] = 'Stage was successfully updated.'
        format.html { redirect_to project_stage_url(current_project, @stage) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @stage.errors.to_xml }
      end
    end
  end

  # DELETE /projects/1/stages/1
  # DELETE /projects/1/stages/1.xml
  def destroy
    @stage = current_project.stages.find(params[:id])
    @stage.destroy

    respond_to do |format|
      flash[:notice] = 'Stage was successfully deleted.'
      format.html { redirect_to project_url(current_project) }
      format.xml  { head :ok }
    end
  end
  
  # GET /projects/1/stages/1/capfile
  # GET /projects/1/stages/1/capifile.xml
  def capfile
    @stage = current_project.stages.find(params[:id])

    respond_to do |format|
      format.html { render :layout => false, :content_type => 'text/plain' }
      format.xml  { render :xml => @stage.to_xml }
    end
  end
  
  # GET | PUT /projects/1/stages/1/recipes
  # GET /projects/1/stages/1/recipes.xml
  def recipes
    @stage = current_project.stages.find(params[:id])
    if request.put?
      @stage.recipe_ids = params[:stage][:recipe_ids] rescue []
      flash[:notice] = "Stage recipes successfully updated."
      redirect_to project_stage_url(current_project, @stage)
    else
      respond_to do |format|
        format.html { render }
        format.xml  { render :xml => @stage.recipes.to_xml }
      end
    end
  end
  
end
