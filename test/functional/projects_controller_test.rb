require File.dirname(__FILE__) + '/../test_helper'

class ProjectsControllerTest < ActionController::TestCase

  def setup
    @project = create_new_project
  end

  def test_should_get_index
    @user = login
    
    get :index
    assert_response :success
    assert assigns(:projects)
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
  
  def test_non_admin_should_not_create_project
    @user = login
    
    Project.delete_all
    old_count = Project.count
    post :create, :project => { :name => 'Project Alpha', :template => 'rails'}
    assert_equal old_count, Project.count
    
    assert_response :redirect
  end

  def test_admin_should_create_project
    @user = admin_login
    
    Project.delete_all
    old_count = Project.count
    post :create, :project => { :name => 'Project Alpha', :template => 'rails'}
    assert_equal old_count+1, Project.count
    
    assert_redirected_to project_path(assigns(:project))
    
    assert_not_nil Project.find(:first).configuration_parameters.find_by_name('scm_username')
  end

  def test_should_show_project
    @user = login
        
    get :show, :id => @project.id
    assert_response :success
  end

  def test_non_admin_should_not_get_edit
    @user = login
    
    get :edit, :id => @project.id
    assert_response :redirect
  end
  
  def test_admin_should_get_edit
    @user = admin_login
    
    get :edit, :id => @project.id
    assert_response :success
  end
  
  def test_non_admin_should_not_update_project
    @user = login
    
    put :update, :id => @project.id, :project => { :name => 'Project Jochen', :template => 'mongrel_rails'}
    assert_response :redirect
    @project.reload
    assert_not_equal 'Project Jochen', @project.name
  end
  
  def test_admin_should_update_project
    @user = admin_login
    
    put :update, :id => @project.id, :project => { :name => 'Project Jochen', :template => 'mongrel_rails'}
    assert_redirected_to project_path(assigns(:project))
    @project.reload
    assert_equal 'mongrel_rails', @project.template
  end
  
  def test_non_admin_should_not_destroy_project
    @user = login
    
    old_count = Project.count
    delete :destroy, :id => @project.id
    assert_equal old_count, Project.count
    
    assert_response :redirect
  end
  
  def test_admin_should_destroy_project
    @user = admin_login
    
    old_count = Project.count
    delete :destroy, :id => @project.id
    assert_equal old_count-1, Project.count
    
    assert_redirected_to projects_path
  end
  
  def test_clone
    @user = admin_login
    @project.template = "mod_rails"
    @project.save!
    assert_difference "Project.count", 1 do
      get :new, :clone => @project.id
      assert_response :success
      assert_select "h2", "Clone project"
      post :create, :clone => @project.id, :project => { :name => 'Project Alpha', :template => 'mongrel_rails'}
      assert_response :redirect
    end
  end
  
end
