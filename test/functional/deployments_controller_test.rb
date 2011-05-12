require File.dirname(__FILE__) + '/../test_helper'

class DeploymentsControllerTest < ActionController::TestCase

  def setup
    @project = create_new_project(:name => 'Project X')
    @stage = create_new_stage(:name => 'Prod', :project => @project)
    @role = create_new_role(:name => 'web', :stage => @stage)
    @deployment = create_new_deployment(:task => 'deploy:setup', :stage => @stage)
    
    @user = login
  end

  def test_should_get_new_if_deployment_possible
    assert @stage.deployment_possible?
    get :new, :project_id => @project.id, :stage_id => @stage.id
    assert_response :success
  end
  
  def test_should_not_get_new_if_deployment_not_possible
    @stage.roles.clear
    assert !@stage.deployment_possible?
    
    get :new, :project_id => @project.id, :stage_id => @stage.id
    assert_response :redirect
  end
  
  def test_should_allow_to_prefil_description
    get :new, :project_id => @project.id, :stage_id => @stage.id, :description => 'hello bert'
    assert_response :success
    assert_match /hello bert/, @response.body
  end
  
  def test_should_create_deployment_if_deployment_possbile
    Deployment.delete_all
    assert @stage.deployment_possible?
    
    post :create, :deployment => { :task => 'deploy:default', :description => 'update to newest' }, :project_id => @project.id, :stage_id => @stage.id
    assert_equal 1, Deployment.count
    assert_equal @user, Deployment.find(:all).last.user
    
    assert_redirected_to project_stage_deployment_path(@project, @stage, assigns(:deployment))
  end
  
  def test_should_not_create_deployment_if_deployment_not_possbile
    @stage.roles.clear
    assert !@stage.deployment_possible?
    
    old_count = Deployment.count
    post :create, :deployment => { :task => 'deploy:default', :description => 'update to newest' }, :project_id => @project.id, :stage_id => @stage.id
    assert_equal old_count, Deployment.count
    
    assert_redirected_to project_stage_path(@project, @stage)
  end

  def test_should_show_deployment
    get :show, :id => @deployment.id, :project_id => @project.id, :stage_id => @stage.id
    assert_response :success
  end
  
  def test_given_task_name
    assert @stage.deployment_possible?
    
    get :new, :task => 'deploy:default' , :project_id => @project.id, :stage_id => @stage.id
    assert_response :success
    assert_equal 'deploy:default', assigns(:deployment).task
  end
  
  def test_prompt_before_deploy
    Deployment.delete_all
    assert @stage.deployment_possible?
    
    # add a config value that wants a promp
    @stage.configuration_parameters.build(:name => 'password', :prompt_on_deploy => 1).save!
    
    get :new, :task => 'deploy:default' , :project_id => @project.id, :stage_id => @stage.id
    assert_response :success
    
    # check that we get asked for the password 
    assert_match /password/, @response.body
    
    # test that we need to enter this parameters
    post :create, :deployment => { :task => 'deploy:default', :description => 'update to newest', :prompt_config => {} }, :project_id => @project.id, :stage_id => @stage.id
    assert_response :success
    assert_equal 0, Deployment.count
    
    # now give the missing config
    post :create, :deployment => { :task => 'deploy:default', :description => 'update to newest', :prompt_config => {:password => 'abc'} }, :project_id => @project.id, :stage_id => @stage.id
    assert_response :redirect
    assert_equal 1, Deployment.count
  end
  
  def test_excluded_hosts
    Deployment.delete_all
    host_down = create_new_host
    down_role = create_new_role(:stage => @stage, :name => 'foo', :host => host_down)
    
    assert_equal 2, @stage.roles.count
    
    post :create, :deployment => { :excluded_host_ids => [host_down.id],:task => 'deploy:default', :description => 'update to newest', :prompt_config => {} }, :project_id => @project.id, :stage_id => @stage.id
    
    assert_equal 1, Deployment.count
    deployment = Deployment.find(:first)
    assert_equal [host_down], deployment.excluded_hosts
    assert_equal [@role], deployment.deploy_to_roles
  end

  def test_latest_deployment
    Deployment.delete_all
    host_down = create_new_host
    down_role = create_new_role(:stage => @stage, :name => 'foo', :host => host_down)
    post :create, :deployment => { :task => 'deploy:default', :description => 'update to newest', :prompt_config => {} }, :project_id => @project.id, :stage_id => @stage.id
    get :latest, :project_id => @project.id, :stage_id => @stage.id
    assert_response :success
    assert_equal "deploy:default", assigns(:deployment).task
  end
  
  def test_latest_with_no_deployment
    Deployment.delete_all
    host_down = create_new_host
    down_role = create_new_role(:stage => @stage, :name => 'foo', :host => host_down)
    get :latest, :project_id => @project.id, :stage_id => @stage.id, :format => "xml"
    assert_response 404
  end
  
  def test_cancel_doenst_respond_to_get
    @deployment.pid = 123
    @deployment.save!
    assert @deployment.running?
    assert @deployment.cancelling_possible?, @deployment.inspect
    get :cancel, :project_id => @project.id, :stage_id => @stage.id, :deployment_id => @deployment.id
    assert_response :redirect
    assert_redirected_to "/"
    @deployment.reload
    assert @deployment.running?
  end
  
  def test_cancel
    @deployment.pid = 123
    @deployment.save!
    assert @deployment.running?
    assert @deployment.cancelling_possible?, @deployment.inspect
    
    Process.expects(:kill).returns(true).times(2)
    
    post :cancel, :project_id => @project.id, :stage_id => @stage.id, :deployment_id => @deployment.id
    assert_response :redirect
    assert_redirected_to project_stage_deployment_path(@project, @stage, @deployment)
    @deployment.reload
    assert @deployment.canceled?, flash[:error]
  end
    
end
