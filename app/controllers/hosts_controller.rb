class HostsController < ApplicationController
  before_filter :ensure_admin, :only => [:new, :edit, :destroy, :create, :update]
  
  # GET /hosts
  # GET /hosts.xml
  def index
    @hosts = Host.find(:all, :order => 'name ASC')

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @hosts.to_xml }
    end
  end

  # GET /hosts/1
  # GET /hosts/1.xml
  def show
    @host = Host.find(params[:id])
    @stages = @host.stages.uniq.sort_by{|x| x.project.name}

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @host.to_xml }
    end
  end

  # GET /hosts/new
  def new
    @host = Host.new
  end

  # GET /hosts/1;edit
  def edit
    @host = Host.find(params[:id])
  end

  # POST /hosts
  # POST /hosts.xml
  def create
    @host = Host.new(params[:host])

    respond_to do |format|
      if @host.save
        flash[:notice] = 'Host was successfully created.'
        format.html { redirect_to host_url(@host) }
        format.xml  { head :created, :location => host_url(@host) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @host.errors.to_xml }
      end
    end
  end

  # PUT /hosts/1
  # PUT /hosts/1.xml
  def update
    @host = Host.find(params[:id])

    respond_to do |format|
      if @host.update_attributes(params[:host])
        flash[:notice] = 'Host was successfully updated.'
        format.html { redirect_to host_url(@host) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @host.errors.to_xml }
      end
    end
  end

  # DELETE /hosts/1
  # DELETE /hosts/1.xml
  def destroy
    @host = Host.find(params[:id])
    @host.destroy

    respond_to do |format|
      flash[:notice] = 'Host was successfully deleted.'
      format.html { redirect_to hosts_url }
      format.xml  { head :ok }
    end
  end
end
