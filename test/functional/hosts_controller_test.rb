require File.dirname(__FILE__) + '/../test_helper'
require 'hosts_controller'

# Re-raise errors caught by the controller.
class HostsController; def rescue_action(e) raise e end; end

class HostsControllerTest < Test::Unit::TestCase
  fixtures :hosts

  def setup
    @controller = HostsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @host = create_new_host
    @user = login
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:hosts)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_host
    old_count = Host.count
    post :create, :host => { :name => '192.168.0.1' }
    assert_equal old_count+1, Host.count
    
    assert_redirected_to host_path(assigns(:host))
  end

  def test_should_show_host
    get :show, :id => @host.id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => @host.id
    assert_response :success
  end
  
  def test_should_update_host
    put :update, :id => @host.id, :host => { :name => 'map.example.com' }
    assert_redirected_to host_path(assigns(:host))
    @host.reload
    assert_equal 'map.example.com', @host.name  
  end
  
  def test_should_destroy_host
    old_count = Host.count
    delete :destroy, :id => @host.id
    assert_equal old_count-1, Host.count
    
    assert_redirected_to hosts_path
  end
end
