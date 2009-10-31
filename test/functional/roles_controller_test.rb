require File.dirname(__FILE__) + '/../test_helper'

class RolesControllerTest < ActionController::TestCase

  def setup
    @project = create_new_project
    @stage = create_new_stage(:project => @project)
    @host = create_new_host
    @role = create_new_role(:stage => @stage, :host => @host)
    @user = login
  end

  def test_should_get_new
    get :new, :project_id => @project.id, :stage_id => @stage.id
    assert_response :success
  end
  
  def test_should_create_role
    old_count = Role.count
    post :create, :project_id => @project.id, :stage_id => @stage.id, :role => { :name => 'a', :value => 'b', :host_id => @host.id }
    assert_equal old_count+1, Role.count
    
    assert_redirected_to project_stage_path(@project, @stage)
  end

  def test_should_get_edit
    get :edit, :project_id => @project.id, :stage_id => @stage.id, :id => @role.id
    assert_response :success
  end
  
  def test_should_update_role
    put :update, :project_id => @project.id, :stage_id => @stage.id, :id => @role.id, :role => { :name => 'a', :value => 'b', :host_id => @host.id}
    assert_redirected_to project_stage_path(@project, @stage)
  end
  
  def test_should_destroy_role
    old_count = Role.count
    delete :destroy, :project_id => @project.id, :stage_id => @stage.id, :id => @role.id
    assert_equal old_count-1, Role.count
    
    assert_redirected_to project_stage_path(@project, @stage)
  end
end
