require File.dirname(__FILE__) + '/../test_helper'

class StageConfigurationTest < ActiveSupport::TestCase
  
  def test_uniqiness_of_name
    p = create_new_project
    s = create_new_stage(:project => p)
    
    # create a new parameter by hand
    config = s.configuration_parameters.build(:name => 'bla_bla', :value => 'blub_blub')
    config.save!
    
    # try to create 
    config = s.configuration_parameters.build(:name => 'bla_bla', :value => 'MAMA_MIA')
    assert !config.valid?
    assert_not_nil config.errors.on('name')
  end
  
end
