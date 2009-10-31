require File.dirname(__FILE__) + '/../test_helper'

class Webistrano::LoggerTest < ActiveSupport::TestCase

  def setup
    @project = create_new_project(:template => 'rails')
    @stage = create_new_stage(:project => @project)
    @host = create_new_host
    
    @stage_with_role = create_new_stage(:project => @project)
    @role = create_new_role(:stage => @stage_with_role, :name => 'web', :host => @host)

  end
  
  def test_initialization
    
    # no deployment given
    assert_raise(ArgumentError){
      logger = Webistrano::Logger.new
    }
    
    assert_raise(NoMethodError){
      logger = Webistrano::Logger.new(nil)
    }
    
    # already completed deployment
    assert_raise(ArgumentError){
      deployment = create_new_deployment(:stage => @stage_with_role, :task => 'deploy:setup')
      deployment.complete_with_error!
      logger = Webistrano::Logger.new( deployment )  
    }
    
    # not completed deployment
    assert_nothing_raised{
      deployment = create_new_deployment(:stage => @stage_with_role, :task => 'deploy:setup')
      assert !deployment.completed?
      logger = Webistrano::Logger.new( deployment )  
    }
    
  end
  
  def test_log
    deployment = create_new_deployment(:stage => @stage_with_role, :task => 'deploy:setup')
    logger = Webistrano::Logger.new( deployment )
    
    logger.level = Webistrano::Logger::TRACE
    
    logger.debug "schu bi du"
    deployment.reload
    assert_equal "  * schu bi du\n", deployment.log
    
    logger.important "schu bi du"
    deployment.reload
    assert_equal "  * schu bi du\n*** schu bi du\n", deployment.log
    
    logger.info "schu bi du"
    deployment.reload
    assert_equal "  * schu bi du\n*** schu bi du\n ** schu bi du\n", deployment.log
    
    logger.trace "schu bi du"
    deployment.reload
    assert_equal "  * schu bi du\n*** schu bi du\n ** schu bi du\n    schu bi du\n", deployment.log
  end
  
  def test_do_no_log_passwords
    pw_config = @stage_with_role.configuration_parameters.find_or_create_by_name('scm_password')
    pw_config.value = 'my_secret'
    pw_config.save!
    
    pw_prompt_config = @stage_with_role.configuration_parameters.find_or_create_by_name('password')
    pw_prompt_config.prompt_on_deploy = 1
    pw_prompt_config.save!
    
    @stage_with_role.reload
    
    deployment = create_new_deployment(:stage => @stage_with_role, :task => 'deploy:setup', :prompt_config => {:password => '@$%deploy@$'})
    logger = Webistrano::Logger.new( deployment )
    logger.level = Webistrano::Logger::TRACE

    logger.info "this is my_secret password"
    deployment.reload
    assert_equal " ** this is XXXXXXXX password\n", deployment.log
    
    logger.info "this is @$%deploy@$ secret password"
    deployment.reload
    assert_equal " ** this is XXXXXXXX password\n ** this is XXXXXXXX secret password\n", deployment.log
  end
  
end