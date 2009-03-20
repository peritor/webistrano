# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  
  skip_before_filter :login_required, :except => :version
  
  # render new.rhtml
  def new
  end

  def create
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default( home_path )
      flash[:notice] = "Logged in successfully"
    else
      flash[:error] = "Login/password wrong"
      render :action => 'new'
    end
  end

  def destroy
    logout
  end
  
  def version
    respond_to do |format|
      format.xml { render :layout => false }
    end
  end
end
