class UsersController < ApplicationController
  before_filter :ensure_admin, :only => [:new, :destroy, :create, :enable]
  before_filter :ensure_admin_or_my_entry, :only => [:edit, :update]

  # GET /users
  # GET /users.xml
  def index
    @users = User.find(:all, :order => 'login ASC')
  end

  # GET /users/new
  def new
    # render new.rhtml
    @user = User.new
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    if current_user.admin?
      @user.admin = params[:user][:admin].to_i rescue 0
    end
    
    respond_to do |format|
      if @user.save
        flash[:notice] = "Account created"
        format.html { redirect_to user_url(@user) }
        format.xml  { head :created, :location => user_url(@user) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
    
  end
  
  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    @deployments = @user.recent_deployments

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @user.to_xml }
    end
  end
  
  # GET /users/edit/1
  def edit
    @user = User.find(params[:id])
  end
  
  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])
    @user.attributes = params[:user]
    
    if current_user.admin?
      @user.admin = params[:user][:admin].to_i rescue 0
    end
    
    respond_to do |format|
      if @user.save
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to user_url(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors.to_xml }
      end
    end
  end
  
  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    
    if @user.admin? && User.admin_count == 1
      message = 'Can not disable last admin user.'
    else
      @user.disable
      message = 'User was successfully disabled.'
    end

    respond_to do |format|
      flash[:notice] = message
      format.html { redirect_to users_url }
      format.xml  { head :ok }
    end
  end
  
  def enable
    @user = User.find(params[:id])
    @user.enable
    flash[:notice] = "The user was enabled"
    
    respond_to do |format|
      format.html { redirect_to users_path }
      format.xml  { head :ok }
    end
  end

  # GET /users/1/deployments
  # GET /users/1/deployments.xml
  def deployments
    @user = User.find(params[:id])
    @deployments = @user.deployments

    respond_to do |format|
      format.html # deployments.rhtml
      format.xml  { render :xml => @user.deployments.to_xml }
    end
  end
  
  protected
  def ensure_admin_or_my_entry
    if current_user.admin? || current_user.id == User.find(params[:id]).id
      return true
    else
      redirect_to home_url
      return false
    end
  end

end
