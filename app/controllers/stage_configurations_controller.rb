class StageConfigurationsController < ApplicationController
  
  before_filter :load_stage
  
  # GET /project/1/stage/1/stage_configurations/1
  # GET /project/1/stage/1/stage_configurations/1.xml
  def show
    @configuration = @stage.configuration_parameters.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @configuration.to_xml }
    end
  end

  # GET /project/1/stage/1/stage_configurations/new
  def new
    @configuration = @stage.configuration_parameters.new
  end

  # GET /project/1/stage/1/stage_configurations/1;edit
  def edit
    @configuration = @stage.configuration_parameters.find(params[:id])
  end

  # POST /project/1/stage/1/stage_configurations
  # POST /project/1/stage/1/stage_configurations.xml
  def create
    @configuration = @stage.configuration_parameters.build(params[:configuration])

    respond_to do |format|
      if @configuration.save
        flash[:notice] = 'StageConfiguration was successfully created.'
        format.html { redirect_to project_stage_url(@project, @stage) }
        format.xml  { head :created, :location => project_stage_url(@project, @stage) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @configuration.errors.to_xml }
      end
    end
  end

  # PUT /project/1/stage/1/stage_configurations/1
  # PUT /project/1/stage/1/stage_configurations/1.xml
  def update
    @configuration = @stage.configuration_parameters.find(params[:id])

    respond_to do |format|
      if @configuration.update_attributes(params[:configuration])
        flash[:notice] = 'StageConfiguration was successfully updated.'
        format.html { redirect_to project_stage_url(@project, @stage) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @configuration.errors.to_xml }
      end
    end
  end

  # DELETE /project/1/stage/1/stage_configurations/1
  # DELETE /project/1/stage/1/stage_configurations/1.xml
  def destroy
    @configuration = @stage.configuration_parameters.find(params[:id])
    @configuration.destroy

    respond_to do |format|
      flash[:notice] = 'StageConfiguration was successfully deleted.'
      format.html { redirect_to project_stage_url(@project, @stage) }
      format.xml  { head :ok }
    end
  end
end
