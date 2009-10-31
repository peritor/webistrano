require File.dirname(__FILE__) + '/../test_helper'

class ProjectConfigurationTest < ActiveSupport::TestCase
  
  def test_templates
    assert_not_nil ProjectConfiguration.templates
    assert_not_nil ProjectConfiguration.templates['rails']
    assert_not_nil ProjectConfiguration.templates['mongrel_rails']
    assert_not_nil ProjectConfiguration.templates['pure_file']
    assert_not_nil ProjectConfiguration.templates['mod_rails']
  end
  
  def test_uniqiness_of_name
    p = Project.new(:name => 'First')
    p.template = 'rails'
    p.save!
    
    # check that we have a param named 'scm_user'
    assert_not_nil p.configuration_parameters.find_by_name('scm_username')
    
    # try to create such a param and fail
    config = p.configuration_parameters.build(:name => 'scm_username', :value => 'MAMA_MIA')
    assert !config.valid?
    assert_not_nil config.errors.on('name')
    
    # create a new parameter by hand
    config = p.configuration_parameters.build(:name => 'bla_bla', :value => 'blub_blub')
    config.save!
    
    # try to create 
    config = p.configuration_parameters.build(:name => 'bla_bla', :value => 'MAMA_MIA')
    assert !config.valid?
    assert_not_nil config.errors.on('name')
  end
end
