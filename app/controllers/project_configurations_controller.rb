class ProjectConfigurationsController < ApplicationController
  
  before_filter :load_project
  
  # GET /projects/1/project_configurations/1
  # GET /projects/1/project_configurations/1.xml
  def show
    @configuration = current_project.configuration_parameters.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @configuration.to_xml }
    end
  end

  # GET /projects/1/project_configurations/new
  def new
    @configuration = current_project.configuration_parameters.new
  end

  # GET /projects/1/project_configurations/1;edit
  def edit
    @configuration = current_project.configuration_parameters.find(params[:id])
  end

  # POST /projects/1/project_configurations
  # POST /projects/1/project_configurations.xml
  def create
    @configuration = current_project.configuration_parameters.build(params[:configuration])

    respond_to do |format|
      if @configuration.save
        flash[:notice] = 'ProjectConfiguration was successfully created.'
        format.html { redirect_to project_url(current_project) }
        format.xml  { head :created, :location => project_url(current_project) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @project_configuration.errors.to_xml }
      end
    end
  end

  # PUT /projects/1/project_configurations/1
  # PUT /projects/1/project_configurations/1.xml
  def update
    @configuration = current_project.configuration_parameters.find(params[:id])

    respond_to do |format|
      if @configuration.update_attributes(params[:configuration])
        flash[:notice] = 'ProjectConfiguration was successfully updated.'
        format.html { redirect_to project_url(current_project) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @configuration.errors.to_xml }
      end
    end
  end

  # DELETE /projects/1/project_configurations/1
  # DELETE /projects/1/project_configurations/1.xml
  def destroy
    @configuration = current_project.configuration_parameters.find(params[:id])
    @configuration.destroy

    respond_to do |format|
      flash[:notice] = 'ProjectConfiguration was successfully deleted.'
      format.html { redirect_to project_url(current_project) }
      format.xml  { head :ok }
    end
  end
end
