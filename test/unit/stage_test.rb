require File.dirname(__FILE__) + '/../test_helper'

class StageTest < ActiveSupport::TestCase
  
  def setup
    Stage.delete_all
    @project = Project.create!(:name => 'Project 1', :template => 'rails')
  end

  def test_creation_and_validation
    assert_equal 0, Stage.count
    
    s = Stage.new(:name => "Beta")
    
    # project is missing
    assert !s.valid?
    assert_not_nil s.errors.on('project')
    
  end
  
  def test_validation
    s = Stage.new(:name => "Beta")
    
    # project is missing
    assert !s.valid?
    assert_not_nil s.errors.on('project')
    
    # make it pass
    s.project = @project
    assert s.save
    
    # try to create another project with the same name
    s = Stage.new(:name => "Beta")
    s.project = @project
    assert !s.valid?
    assert_not_nil s.errors.on("name")
    
    # try to create a stage with a name that is too long
    name = "x" * 251
    s = Stage.new(:name => name)
    s.project = @project
    assert !s.valid?
    assert_not_nil s.errors.on("name")

    # make it pass
    s.name = name.chop
    assert s.save
  end

  def test_deployment_possible_roles
    project = create_new_project(:template => 'rails')
    stage = create_new_stage(:project => project)
    assert stage.roles.blank?
    
    # no roles, no deployment
    assert !stage.deployment_possible?
    assert_not_nil stage.deployment_problems[:roles]
    
    role = create_new_role(:stage => stage)
    stage = Stage.find(stage.id) # stage.reload would not clear attr_accessor
    
    assert stage.deployment_possible?
    assert_nil stage.deployment_problems[:roles]
  end
  
  def test_deployment_possible_vars
    project = create_new_project(:template => 'rails')
    stage = create_new_stage(:project => project)
    role = create_new_role(:stage => stage)

    assert_not_nil stage.effective_configuration(:repository)
    assert_not_nil stage.effective_configuration(:application)
    
    # roles and config present => go
    assert stage.deployment_possible?
    
    # remove a config
    stage.configuration_parameters.find_by_name('repository').destroy rescue nil
    project.configuration_parameters.find_by_name('repository').destroy rescue nil
    
    stage = Stage.find(stage.id) # stage.reload would not clear attr_accessor
    
    assert_nil stage.effective_configuration(:repository)
    assert_not_nil stage.effective_configuration(:application)
    
    assert !stage.deployment_possible?
    assert_not_nil stage.deployment_problems[:repository]
    assert_nil stage.deployment_problems[:application]
    
    # add it again
    config = stage.configuration_parameters.build(:name => 'repository', :value => 'svn://bla.com/trunk')
    config.save!
    stage = Stage.find(stage.id) # stage.reload would not clear attr_accessor
    
    assert_not_nil stage.effective_configuration(:repository)
    assert_not_nil stage.effective_configuration(:application)
    assert stage.deployment_possible?
    assert stage.deployment_problems.blank?
    
    # remove the other one
    # remove a config
    stage.configuration_parameters.find_by_name('application').destroy rescue nil
    project.configuration_parameters.find_by_name('application').destroy rescue nil
    
    stage = Stage.find(stage.id) # stage.reload would not clear attr_accessor
    
    assert !stage.deployment_possible?
    assert_not_nil stage.effective_configuration(:repository)
    assert_nil stage.effective_configuration(:application)
    assert_nil stage.deployment_problems[:repository]
    assert_not_nil stage.deployment_problems[:application]
    
  end
  
  def test_deployment_problems_can_be_called_with_explicit_check_with_deployment_possible
    stage = create_new_stage
    
    assert_nothing_raised{
      stage.deployment_problems[:application]
    }
  end
  
  def test_configs_that_need_prompt
    ProjectConfiguration.delete_all
    @stage = create_new_stage(:project => @project, :name => 'Production')
    @stage.reload
    
    # create two config entries, one that need a prompt
    @stage.configuration_parameters.build(:name => 'user', :value => 'deploy').save!
    @stage.configuration_parameters.build(:name => 'password', :prompt_on_deploy => 1).save!
    
    assert_equal 1, @stage.prompt_configurations.size
    assert_equal 1, @stage.non_prompt_configurations.size
  end
  
  def test_alert_emails_format
    stage = create_new_stage
    assert_nil stage.alert_emails
    
    stage.alert_emails = "michael@jackson.com"    
    assert stage.valid?
    
    stage.alert_emails = "michael@example.com me@example.com"    
    assert stage.valid?
    assert_equal ['michael@example.com', 'me@example.com'], stage.emails
    
    stage.alert_emails = "michael@example.com me@example.com 123"    
    assert !stage.valid?
    
    stage.alert_emails = "michael@example.com You <me@example.com>"    
    assert !stage.valid?
    
    stage.alert_emails = "michael"    
    assert !stage.valid?
  end
  
  def test_recent_deployments
    stage = create_new_stage
    role = create_new_role(:stage => stage)
    5.times do 
      deployment = create_new_deployment(:stage => stage)
    end
    
    assert_equal 5, stage.deployments.count
    assert_equal 3, stage.recent_deployments.size
    assert_equal 2, stage.recent_deployments(2).size
  end
  
  def test_webistrano_stage_name
    stage = create_new_stage(:name => '&my_ Pro ject')
    assert_equal '_my__pro_ject', stage.webistrano_stage_name
  end
  
  def test_handle_corrupt_recipes
    stage = create_new_stage
    
    # create a recipe with invalid code
    recipe = create_new_recipe(:body => <<-'EOS'
      namescape do
        task :foo do
          run 'ls'
        end
      end
      EOS
    )
    
    assert_nothing_raised do
      stage.recipes << recipe
      stage.list_tasks
    end
  end
  
  def test_locking_methods
    stage = create_new_stage
    assert !stage.locked?
    
    stage.lock
    
    assert stage.locked?, stage.inspect
    
    stage.unlock
    
    assert !stage.locked?
  end
  
  def test_lock_info
    stage = create_stage_with_role
    deployment = create_new_deployment(:stage => stage)
    stage.lock
    stage.lock_with(deployment)
    
    stage.reload
    assert_equal deployment, stage.locking_deployment
    
    stage.unlock
    assert_nil stage.locking_deployment
  end
  
  def test_lock_with_can_not_be_called_without_being_locked
    stage = create_stage_with_role
    deployment = create_new_deployment(:stage => stage)
    assert !stage.locked?
    
    assert_raise(ArgumentError) do
      stage.lock_with(deployment)
    end
  end
  
  def test_locked_deployment_belongs_to_stage
    stage_1 = create_stage_with_role
    deployment_1 = create_new_deployment(:stage => stage_1)
    stage_2 = create_stage_with_role
    deployment_2 = create_new_deployment(:stage => stage_2)
    
    stage_1.lock
    assert_raise(ArgumentError) do
      stage_1.lock_with(deployment_2)
    end
  end
  
end
