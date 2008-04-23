require File.dirname(__FILE__) + '/../test_helper'

class DeploymentTest < Test::Unit::TestCase

  def setup
    @stage = create_new_stage
    @role_app = create_new_role(:name => 'app', :stage => @stage)
    @role_www = create_new_role(:name => 'app', :stage => @stage)
    
    @deployment = create_new_deployment(:stage => @stage, :roles => [@role_app, @role_www], :description => 'update code to newest')
  end

  def test_creation
    Deployment.delete_all
    assert_equal 0, Deployment.count
    
    d = nil
    assert_nothing_raised{
      d = Deployment.new(:task => 'deploy:setup') 
      d.stage = @stage
      d.description = "Update to newest version"
      d.user = create_new_user
      d.save!
    }
    
    assert_equal 1, Deployment.count
    assert_equal [d], Role.find(@role_www.id).deployments
    assert_equal [d], Role.find(@role_app.id).deployments
    assert_equal [d], Stage.find(@stage.id).deployments
    assert_equal [@role_app.id, @role_www.id].sort, Deployment.find(d.id).roles.collect(&:id).sort
    
    assert !d.completed?
    assert_equal 'running', d.status
  end
  
  def test_validation
    # task and stage missing
    d = Deployment.new
    assert !d.valid?
    assert_not_nil d.errors.on('task')
    assert_not_nil d.errors.on('stage')
    assert_not_nil d.errors.on('description')
    assert_not_nil d.errors.on('user')
    
    # fix it
    d.stage = @stage
    assert !d.valid?
    assert_not_nil d.errors.on('user')
    assert_not_nil d.errors.on('description')
    assert_not_nil d.errors.on('task')
    assert_nil d.errors.on('stage')
    d.task = 'deploy:setup'
    assert !d.valid?
    assert_not_nil d.errors.on('user')
    assert_not_nil d.errors.on('description')
    assert_nil d.errors.on('task')
    assert_nil d.errors.on('stage')
    d.description = 'update to newest'
    assert !d.valid?
    assert_not_nil d.errors.on('user')
    assert_nil d.errors.on('description')
    assert_nil d.errors.on('task')
    assert_nil d.errors.on('stage')
    
    d.user = create_new_user
    assert d.valid?
    assert_nil d.errors.on('user')
    assert_nil d.errors.on('description')
    assert_nil d.errors.on('task')
    assert_nil d.errors.on('stage')
    
    # try success values
    d.success = 3
    assert !d.valid?
    assert_not_nil d.errors.on('success')
    d.success = 1
    assert d.valid?
    assert_nil d.errors.on('success')
  end
  
  def test_completed_and_status_on_error
    assert !@deployment.completed?
    assert !@deployment.success?
    assert_equal 'running', @deployment.status
    
    @deployment.complete_with_error!
    
    assert @deployment.completed?
    assert !@deployment.success?
    assert_equal 'failed', @deployment.status
    
    # second completion is not possible
    assert_raise(RuntimeError){
      @deployment.complete_successfully! 
    }
  end
  
  def test_completed_and_status_on_success
    assert !@deployment.completed?
    assert !@deployment.success?
    assert_equal 'running', @deployment.status
    
    @deployment.complete_successfully!
    
    assert @deployment.completed?
    assert @deployment.success?
    assert_equal 'success', @deployment.status
    
    # second completion is not possible
    assert_raise(RuntimeError){
      @deployment.complete_with_error! 
    }
  end
  
  def test_validation_depends_on_stage_ready_to_deploy
    project = create_new_project(:template => 'rails')
    stage = create_new_stage(:project => project)
    role = create_new_role(:stage => stage)
    
    assert stage.deployment_possible?
    
    deployment = Deployment.new(:task => 'shell')
    deployment.stage = stage
    deployment.description = 'description'
    deployment.user = create_new_user
    deployment.roles << role
    
    assert deployment.valid?
    
    # now make stage not possible to deploy
    stage.configuration_parameters.find_by_name('repository').destroy rescue nil
    project.configuration_parameters.find_by_name('repository').destroy rescue nil
    stage = Stage.find(stage.id) # stage.reload would not clear attr_accessor
    
    assert !stage.deployment_possible?
    
    deployment = Deployment.new(:task => 'shell')
    deployment.stage = stage
    deployment.roles << role
    
    assert !deployment.valid?
    assert_match /is not ready to deploy/, deployment.errors.on('stage')
  end
  
  def test_check_of_stage_prompt_configuration_in_validation
    # add a config value that wants a promp
    @stage.configuration_parameters.build(:name => 'password', :prompt_on_deploy => 1).save!
    
    assert !@stage.prompt_configurations.empty?
    
    deployment = Deployment.new
    deployment.stage = @stage
    deployment.task = 'deploy'
    deployment.description = 'bugfix'
    deployment.user = create_new_user
    deployment.roles << @stage.roles
    
    assert !deployment.valid?
    assert_not_nil deployment.errors.on('base')
    assert_match /password/, deployment.errors.on('base').inspect
    
    # now give empty pw
    deployment.prompt_config = {:password => ''}
    
    assert !deployment.valid?
    assert_not_nil deployment.errors.on('base')
    assert_match /password/, deployment.errors.on('base').inspect
    
    # now give pw
    deployment.prompt_config = {:password => 'abc'}
    
    assert deployment.valid?, deployment.errors.inspect
    assert_nil deployment.errors.on('base')
  end
  
  def test_prompt_config_init
    deployment = Deployment.new
    
    expected_prompt_config = {}
    assert_equal expected_prompt_config, deployment.prompt_config
    
    dep = create_new_deployment(:stage => @stage)
    
    assert Deployment.count > 0
    
    assert_equal expected_prompt_config, Deployment.find(dep.id).prompt_config
  end
  
  def test_completion_alerts_per_mail_when_no_alert_emails_set
    # prepare ActionMailer
    emails = prepare_email
    
    @deployment = create_new_deployment(:stage => @stage)
    
    # no alert emails set
    assert_nil @stage.alert_emails
    @deployment.complete_with_error!
    
    # no alert was sent
    assert emails.empty?
  end
  
  def test_completion_alerts_per_mail_when_alert_emails_set_on_error
    # prepare ActionMailer
    emails = prepare_email
    
    @deployment = create_new_deployment(:stage => @stage)
    
    # alert emails set
    @stage.alert_emails = "michael@example.com you@example.com"
    @stage.save!
    
    assert_not_nil @stage.alert_emails
    @deployment.complete_with_error!
    
    # alert was sent to both
    assert_equal 2, emails.size
  end
  
  def test_repeat
    original = create_new_deployment(:stage => @stage, :description => 'this is foo', :task => 'foo:bar')
    
    repeater = original.repeat
    
    assert_equal original.task, repeater.task
    assert_equal "Repetition of deployment #{original.id}:\n\n#{original.description}", repeater.description
  end
  
  def test_excluded_hosts_accessor
    host = create_new_host
    deployment = create_new_deployment(:excluded_host_ids => [host.id], :stage => @stage)

    assert_equal [host.id], deployment.excluded_host_ids
    assert_equal [host], deployment.excluded_hosts
    
    deployment.excluded_host_ids = host.id.to_s
    assert_equal [host.id], deployment.excluded_host_ids
  end
  
  def test_excluded_hosts
    host_1 = create_new_host
    host_2 = create_new_host
    stage = create_new_stage
    role_app = create_new_role(:name => 'app', :stage => stage, :host => host_1)
    role_www = create_new_role(:name => 'www', :stage => stage, :host => host_2)
    role_db = create_new_role(:name => 'db', :stage => stage, :host => host_2)
    
    stage.reload
    assert_equal 3, stage.roles.count
    deployment = create_new_deployment(
                  :stage => stage, 
                  :excluded_host_ids => [host_1.id])
    
    assert_equal 3, deployment.roles.count
    assert_equal [host_1], deployment.excluded_hosts
                  
    assert_equal [host_2], deployment.deploy_to_hosts
    assert_equal [role_www, role_db].map(&:id).sort, deployment.deploy_to_roles.map(&:id).sort
  end
  
  def test_cannot_exclude_all_hosts
    stage = create_new_stage
    host = create_new_host
    role_app = create_new_role(:name => 'app', :stage => stage, :host => host)
    
    d = Deployment.new
    d.task = 'foo'
    d.stage = stage
    d.description = 'foo bar'
    d.excluded_host_ids = role_app.host.id
    d.user = create_new_user

    assert !d.valid?
    assert d.errors.on('base')
  end
  
  
end
