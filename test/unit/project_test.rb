require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < Test::Unit::TestCase

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
  
end
