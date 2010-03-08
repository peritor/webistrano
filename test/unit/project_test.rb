require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < ActiveSupport::TestCase

  def test_creation
    assert_equal 0, Project.count
    
    assert_nothing_raised{
      p = Project.create!(:name => "Project Alpha", :template => 'rails') 
    }
    
    assert_equal 1, Project.count
  end
  
  def test_validation
    p = Project.create(:name => "Project Alpha", :template => 'rails')
    assert p.save, p.errors.inspect + p.attributes.inspect
    
    # try to create another project with the same name
    p = Project.new(:name => "Project Alpha")
    assert !p.valid?
    assert_not_nil p.errors.on("name")
    
    # try to create a project with a name that is too long
    name = "x" * 251
    p = Project.new(:name => name, :template => 'rails')
    assert !p.valid?
    assert_not_nil p.errors.on("name")
    
    # make it pass
    name = name.chop
    p = Project.new(:name => name, :template => 'rails')
    assert p.valid?
    
    # test template validation
    p = Project.new(:name => "Project XXXX")
    p.template = 'bla_bla'
    assert !p.valid?
    assert_not_nil p.errors.on("template")
    assert_match /is not/, p.errors.on("template")
    
    # fix template validation
    p.template = 'rails'
    assert p.valid?
  end
  
  def test_default_config
    # choose a template on project creation
    p = Project.new(:name => "Project Alpha")
    p.template = 'rails'
    p.save!
    
    # check that we now have a sample configuration
    assert !p.configuration_parameters.empty?
    
    # from BASE
    assert_not_nil p.configuration_parameters.find_by_name('scm_username')
    assert_not_nil p.configuration_parameters.find_by_name('scm_password')
    
    # from RAILS
    assert_not_nil p.configuration_parameters.find_by_name('rails_env')
    
    # check that symbols arrive ok
    assert_equal ':checkout', p.configuration_parameters.find_by_name('deploy_via').value
    
    # check the default :application
    assert_equal 'project_alpha', p.configuration_parameters.find_by_name('application').value
  end
  
  def test_tasks
    # choose a template on project creation
    p = Project.new(:name => "Project Alpha")
    p.template = 'mongrel_rails'
    p.save!
    
    assert_not_nil p.tasks
    assert_equal ProjectConfiguration.templates['mongrel_rails']::TASKS, p.tasks
    assert_match /namespace/, p.tasks
  end
  
  def test_webistrano_project_name
    project = create_new_project(:name => '&my_ Project')
    assert_equal '_my__project', project.webistrano_project_name
  end
  
  def test_prepare_cloning
    original = create_new_project(:name => 'Some Project', :template => 'mod_rails', :description => "Dr. Foo")
    my = create_new_project(:template => 'mongrel_rails')
    
    my.prepare_cloning(original)
    assert_equal "Clone of Some Project", my.name
    assert_equal "Clone of Some Project: Dr. Foo", my.description
    assert_equal original.template, my.template
  end
  
  def test_clone
    # setup
    original = create_new_project(:name => 'Some Project', :template => 'mod_rails')
    3.times do |i|
      create_new_project_configuration(:project => original, :name => "#{i}-project-conf", :value => "value-#{i}")
    end
    stage_1 = create_new_stage(:project => original, :name => 'test')
      create_new_stage_configuration(:stage => stage_1, :name => "stage1-conf", :value => "stage1-value")
    stage_2 = create_new_stage(:project => original, :name => 'prod')
      create_new_stage_configuration(:stage => stage_2, :name => "stage2-conf", :value => "stage2-value")
    recipe = create_new_recipe
    stage_1.recipes << recipe
    
    host = Host.new(:name => '192.168.0.1')
    r = Role.new(:name => 'web') 
    r.stage = stage_1
    r.host = host
    r.save!
      
    new_project = create_new_project
    new_project.clone(original)
    
    # check project configuration
    assert_equal original.configuration_parameters.count, new_project.configuration_parameters.count
    new_project.configuration_parameters.each_with_index do |conf, i|
      orig = original.configuration_parameters.find_by_name(conf.name)
      
      if conf.name == 'application'
        assert_match 'some_project',conf.value
      else
        assert_equal orig.name, conf.name
        assert_equal orig.value, conf.value
        assert_equal orig.prompt_on_deploy, conf.prompt_on_deploy
      end
    end

    # check stages
    assert_equal 2, new_project.stages.count
    cloned_stage_1 = new_project.stages.find_by_name("test")
    cloned_stage_2 = new_project.stages.find_by_name("prod")
    assert_equal stage_1.configuration_parameters.first.name, cloned_stage_1.configuration_parameters.first.name 
    assert_equal stage_1.configuration_parameters.first.value, cloned_stage_1.configuration_parameters.first.value
    assert_equal stage_2.configuration_parameters.first.name, cloned_stage_2.configuration_parameters.first.name 
    assert_equal stage_2.configuration_parameters.first.value, cloned_stage_2.configuration_parameters.first.value
    assert_equal [recipe], cloned_stage_1.recipes
    
    # check roles
    assert_equal 1, cloned_stage_1.roles.size
    assert_equal host, cloned_stage_1.roles.first.host
  end
  
  def test_recent_deployments
    project = create_new_project
    
    stage_1 = create_new_stage(:project => project)
    role = create_new_role(:stage => stage_1)
    5.times do 
      deployment = create_new_deployment(:stage => stage_1)
    end
    
    stage_2 = create_new_stage(:project => project)
    role = create_new_role(:stage => stage_2)
    5.times do 
      deployment = create_new_deployment(:stage => stage_2)
    end
    
    assert_equal 10, project.deployments.count
    assert_equal 3, project.recent_deployments.size
    assert_equal 2, project.recent_deployments(2).size
  end
  
end
