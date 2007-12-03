class RolesController < ApplicationController
  
  before_filter :load_stage
  before_filter :load_host_choices, :only => [:new, :edit, :update, :create]
  
  # GET /projects/1/stages/1/roles/1
  # GET /projects/1/stages/1/roles/1.xml
  def show
    @role = @stage.roles.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @role.to_xml }
    end
  end

  # GET /projects/1/stages/1/roles/new
  def new
    @role = @stage.roles.new
  end

  # GET /projects/1/stages/1/roles/1;edit
  def edit
    @role = @stage.roles.find(params[:id])
  end

  # POST /projects/1/stages/1/roles
  # POST /projects/1/stages/1/roles.xml
  def create
    @role = @stage.roles.build(params[:role])

    respond_to do |format|
      if @role.save
        flash[:notice] = 'Role was successfully created.'
        format.html { redirect_to project_stage_url(@project, @stage) }
        format.xml  { head :created, :location => project_stage_url(@project, @stage) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @role.errors.to_xml }
      end
    end
  end

  # PUT /projects/1/stages/1/roles/1
  # PUT /projects/1/stages/1/roles/1.xml
  def update
    @role = @stage.roles.find(params[:id])

    respond_to do |format|
      if @role.update_attributes(params[:role])
        flash[:notice] = 'Role was successfully updated.'
        format.html { redirect_to project_stage_url(@project, @stage) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @role.errors.to_xml }
      end
    end
  end

  # DELETE /projects/1/stages/1/roles/1
  # DELETE /projects/1/stages/1/roles/1.xml
  def destroy
    @role = @stage.roles.find(params[:id])
    @role.destroy

    respond_to do |format|
      flash[:notice] = 'Role was successfully deleted.'
      format.html { redirect_to project_stage_url(@project, @stage) }
      format.xml  { head :ok }
    end
  end
  
  protected
  def load_host_choices
    @host_choices = Host.find(:all, :order => "name ASC").collect {|h| [ h.name, h.id ] }
  end
end
