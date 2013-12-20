class AuthSourcesController < ApplicationController
  before_filter :ensure_admin
  
  def index
    @auth_sources = auth_source_class.all
    render "auth_sources/index"
  end

  def new
    @auth_source = auth_source_class.new
    render 'auth_sources/new'
  end

  def create
    @auth_source = auth_source_class.new(params[:auth_source])
    if @auth_source.save
      flash[:notice] = 'Successful creation.'
      redirect_to :action => 'index'
    else
      render 'auth_sources/new'
    end
  end

  def edit
    @auth_source = AuthSource.find(params[:id])
    render 'auth_sources/edit'
  end

  def update
    @auth_source = AuthSource.find(params[:id])
    if @auth_source.update_attributes(params[:auth_source])
      flash[:notice] = 'Successful update.'
      redirect_to :action => 'index'
    else
      render 'auth_sources/edit'
    end
  end

  def test_connection
    @auth_method = AuthSource.find(params[:id])
    begin
      @auth_method.test_connection
      flash[:notice] = 'Successful connection.'
    rescue => text
      flash[:error] = "Unable to connect (#{text.message})"
    end
    redirect_to :action => 'index'
  end

  def destroy
    @auth_source = AuthSource.find(params[:id])
    unless @auth_source.users.find(:first)
      @auth_source.destroy
      flash[:notice] = 'Successful deletion.'
    end
    redirect_to :action => 'index'
  end

  protected

  def auth_source_class
    AuthSourceLdap
  end
end
