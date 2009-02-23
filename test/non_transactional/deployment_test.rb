require File.dirname(__FILE__) + '/../non_transactional_test_helper'

class DeploymentTest < Test::Unit::TestCase
  
  def setup
    User.destroy_all
    Project.destroy_all
    Deployment.delete_all
  end
  
  def test_locking_of_stage_through_lock_and_fire
    stage = create_stage_with_role
    assert !stage.locked?
    
    res = Deployment.lock_and_fire do |deployment|
      deployment.user  = create_new_user
      deployment.stage = stage
      deployment.task  = 'deploy'
    end
    
    stage.reload
    assert stage.locked?
    assert res
  end
  
  def test_lock_and_fire_handles_transaction_abort
    stage = create_stage_with_role
    assert !stage.locked?
    res = Deployment.lock_and_fire do |deployment|
      deployment.user  = create_new_user
      deployment.stage = stage
      deployment.task  = 'deploy'
      deployment.expects(:save!).raises(ActiveRecord::RecordInvalid)
    end
    
    stage.reload
    assert !stage.locked?
    assert !res
  end
  
  def test_lock_and_fire_sets_locking_deployment
    stage = create_stage_with_role
    assert !stage.locked?
    res = Deployment.lock_and_fire do |deployment|
      deployment.user  = create_new_user(:login => 'MasterBlaster')
      deployment.stage = stage
      deployment.task  = 'deploy'
    end
    
    assert res
    stage.reload
    assert_not_nil stage.locking_deployment
    assert_equal Deployment.last, stage.locking_deployment
    assert_equal 'MasterBlaster', stage.locking_deployment.user.login
  end
  
  def test_lock_and_fire_handles_transaction_abort_if_stage_breaks
    stage = create_stage_with_role
    assert !stage.locked?
    res = Deployment.lock_and_fire do |deployment|
      deployment.user  = create_new_user
      deployment.stage = stage
      deployment.task  = 'deploy'
      Stage.any_instance.stubs(:lock).raises(ActiveRecord::RecordInvalid)
    end
    
    stage.reload
    assert !stage.locked?
    assert !res
  end
  
end
