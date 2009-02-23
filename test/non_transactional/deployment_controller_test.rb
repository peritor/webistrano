require File.dirname(__FILE__) + '/../non_transactional_test_helper'
require 'deployments_controller'

# Re-raise errors caught by the controller.
class DeploymentsController; def rescue_action(e) raise e end; end

class DeploymentsControllerTest < Test::Unit::TestCase
  def setup
    Project.destroy_all
    @controller = DeploymentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @project = create_new_project(:name => 'Project X')
    @stage = create_new_stage(:name => 'Prod', :project => @project)
    @role = create_new_role(:name => 'web', :stage => @stage)
    @deployment = create_new_deployment(:task => 'deploy:setup', :stage => @stage)
    
    @user = login
  end

  def test_locking_checked
    @stage.lock
    assert_no_difference "Deployment.count" do
      post :create, :deployment => { :task => 'deploy:default', :description => 'update to newest' }, :project_id => @project.id, :stage_id => @stage.id
    end

    assert_response :success
  end
  
  def test_locking_override
    @stage.lock
    assert_difference "Deployment.count" do
      post :create, :deployment => { :task => 'deploy:default', :description => 'update to newest', :override_locking => 1 }, :project_id => @project.id, :stage_id => @stage.id
    end

    assert_response :redirect
  end
  
  def test_stage_locked_after_deploy
    assert !@stage.locked?
    assert_difference "Deployment.count" do
      post :create, :deployment => { :task => 'deploy:default', :description => 'update to newest' }, :project_id => @project.id, :stage_id => @stage.id
    end

    assert_response :redirect
    assert @stage.reload.locked?
  end
    
end


