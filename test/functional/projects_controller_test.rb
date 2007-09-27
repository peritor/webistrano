require File.dirname(__FILE__) + '/../test_helper'
require 'projects_controller'

# Re-raise errors caught by the controller.
class ProjectsController; def rescue_action(e) raise e end; end

class ProjectsControllerTest < Test::Unit::TestCase
  fixtures :projects

  def setup
    @controller = ProjectsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @project = create_new_project
    @user = login
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:projects)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_project
    Project.delete_all
    old_count = Project.count
    post :create, :project => { :name => 'Project Alpha', :template => 'rails'}
    assert_equal old_count+1, Project.count
    
    assert_redirected_to project_path(assigns(:project))
    
    assert_not_nil Project.find(:first).configuration_parameters.find_by_name('scm_username')
  end

  def test_should_show_project    
    get :show, :id => @project.id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => @project.id
    assert_response :success
  end
  
  def test_should_update_project
    put :update, :id => @project.id, :project => { :name => 'Project Jochen', :template => 'mongrel_rails'}
    assert_redirected_to project_path(assigns(:project))
    @project.reload
    assert_equal 'mongrel_rails', @project.template
  end
  
  def test_should_destroy_project
    old_count = Project.count
    delete :destroy, :id => @project.id
    assert_equal old_count-1, Project.count
    
    assert_redirected_to projects_path
  end
  
end
