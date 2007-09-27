require File.dirname(__FILE__) + '/../test_helper'
require 'stage_configurations_controller'

# Re-raise errors caught by the controller.
class StageConfigurationsController; def rescue_action(e) raise e end; end

class StageConfigurationsControllerTest < Test::Unit::TestCase
  fixtures :stage_configurations

  def setup
    @controller = StageConfigurationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @project = create_new_project
    @stage = create_new_stage(:project => @project)
    @config = create_new_stage_configuration(:stage => @stage)
    @user = login
  end

  def test_should_get_new
    get :new, :project_id => @project.id, :stage_id => @stage.id
    assert_response :success
  end
  
  def test_should_create_stage_configuration
    old_count = StageConfiguration.count
    post :create, :project_id => @project.id, :stage_id => @stage.id, :configuration => { :name => 'a', :value => 'b' }
    assert_equal old_count+1, StageConfiguration.count
    
    assert_redirected_to project_stage_path(@project, @stage)
  end

  def test_should_get_edit
    get :edit, :project_id => @project.id, :stage_id => @stage.id, :id => @config.id
    assert_response :success
  end
  
  def test_should_update_stage_configuration
    put :update, :project_id => @project.id, :stage_id => @stage.id, :id => @config.id, :configuration => { :name => 'a', :value => 'b'}
    assert_redirected_to project_stage_path(@project, @stage)
  end
  
  def test_should_destroy_stage_configuration
    old_count = StageConfiguration.count
    delete :destroy, :project_id => @project.id, :stage_id => @stage.id, :id => @config.id
    assert_equal old_count-1, StageConfiguration.count
    
    assert_redirected_to project_stage_path(@project, @stage)
  end
end
