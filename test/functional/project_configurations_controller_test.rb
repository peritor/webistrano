require File.dirname(__FILE__) + '/../test_helper'

class ProjectConfigurationsControllerTest < ActionController::TestCase

  def setup
    @project = create_new_project
    @config = create_new_project_configuration(:project => @project)
    @user = login
  end

  def test_should_get_new
    get :new, :project_id => @project.id
    assert_response :success
  end
  
  def test_should_create_project_configuration
    old_count = ProjectConfiguration.count
    post :create, :project_id => @project.id, :configuration => { :name => 'a', :value => 'b' }
    assert_equal old_count+1, ProjectConfiguration.count
    
    assert_redirected_to project_path(@project)
  end

  def test_should_get_edit
    get :edit, :project_id => @project.id, :id => @config.id
    assert_response :success
  end
  
  def test_should_update_project_configuration
    put :update, :project_id => @project.id, :id => @config.id, :configuration => { :name => 'a', :value => 'b'}
    assert_redirected_to project_path(@project)
  end
  
  def test_should_destroy_project_configuration
    old_count = ProjectConfiguration.count
    delete :destroy, :project_id => @project.id, :id => @config.id
    assert_equal old_count-1, ProjectConfiguration.count
    
    assert_redirected_to project_path(@project)
  end
end
