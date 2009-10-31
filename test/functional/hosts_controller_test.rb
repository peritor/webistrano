require File.dirname(__FILE__) + '/../test_helper'

class HostsControllerTest < ActionController::TestCase

  def setup
    @host = create_new_host
  end

  def test_should_get_index
    @user = login
    
    get :index
    assert_response :success
    assert assigns(:hosts)
  end

  def test_non_admin_should_not_get_new
    @user = login
    
    get :new
    assert_response :redirect
  end
  
  def test_admin_should_get_new
    @user = admin_login
    
    get :new
    assert_response :success
  end
  
  def test_non_admin_should_not_create_host
    @user = login
    
    old_count = Host.count
    post :create, :host => { :name => '192.168.0.1' }
    assert_equal old_count, Host.count
    
    assert_response :redirect
  end
  
  def test_admin_should_create_host
    @user = admin_login
    
    old_count = Host.count
    post :create, :host => { :name => '192.168.0.1' }
    assert_equal old_count+1, Host.count
    
    assert_redirected_to host_path(assigns(:host))
  end

  def test_should_show_host
    @user = login
    
    get :show, :id => @host.id
    assert_response :success
  end

  def test_non_admin_should_not_get_edit
    @user = login
    
    get :edit, :id => @host.id
    assert_response :redirect
  end
  
  def test_admin_should_get_edit
    @user = admin_login
    
    get :edit, :id => @host.id
    assert_response :success
  end
  
  def test_non_admin_should_not_update_host
    @user = login
    
    put :update, :id => @host.id, :host => { :name => 'map.example.com' }
    assert_response :redirect
    @host.reload
    assert_not_equal 'map.example.com', @host.name  
  end
  
  def test_admin_should_update_host
    @user = admin_login
    
    put :update, :id => @host.id, :host => { :name => 'map.example.com' }
    assert_redirected_to host_path(assigns(:host))
    @host.reload
    assert_equal 'map.example.com', @host.name  
  end
  
  def test_non_admin_should_not_destroy_host
    @user = login
    
    old_count = Host.count
    delete :destroy, :id => @host.id
    assert_equal old_count, Host.count
    
    assert_response :redirect
  end
  
  def test_should_destroy_host
    @user = admin_login
    
    old_count = Host.count
    delete :destroy, :id => @host.id
    assert_equal old_count-1, Host.count
    
    assert_redirected_to hosts_path
  end
end
