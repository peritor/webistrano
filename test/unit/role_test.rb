require File.dirname(__FILE__) + '/../test_helper'

class RoleTest < ActiveSupport::TestCase

  def setup
    @stage = create_new_stage
    @host = Host.new(:name => '192.168.0.1')
  end

  def test_creation
    Role.delete_all
    assert_equal 0, Role.count
    
    assert_nothing_raised{
      r = Role.new(:name => 'web') 
      r.stage = @stage
      r.host = @host
      r.save!
      
      assert_equal 0, r.primary
      assert_equal 0, r.no_release
      
      assert !r.primary?
      assert !r.no_release?
    }
    
    assert_equal 1, Role.count
  end
  
  def test_validation
    r = Role.new(:name => 'web') 
    
    # stage is missing
    assert !r.valid?
    assert_not_nil r.errors.on('stage')
    
    # host is missing
    assert !r.valid?
    assert_not_nil r.errors.on('host')
    
    # make it pass
    r.stage = @stage
    r.host = @host
    assert r.valid?
    assert r.save
    
    # try to create a role with a name that is too long
    name = "x" * 251
    r = Role.new(:name => name)
    r.stage = @stage
    r.host = @host
    assert !r.valid?
    assert_not_nil r.errors.on("name")

    # make it pass
    assert_equal 250, name.chop.size
    r.name = name.chop
    r.custom_name = name.chop
    assert r.save, r.errors.inspect
  end
  
  # test that a host should only have a role once
  def test_only_once_per_role_per_host_per_stage
    r = Role.new(:name => 'web')
    r.host = @host
    r.stage = @stage
    assert r.save
    
    # now try another role for this host
    r = Role.new(:name => 'web')
    r.host = @host
    r.stage = @stage
    assert !r.valid?
    assert_not_nil r.errors.on('name')
    
    # fix it
    r.name = 'app'
    assert r.valid?
  end
  
  def test_primary
    r = create_new_role(:name => 'app')
    
    assert_equal 0, r.primary
    assert !r.primary?
    
    r.set_as_primary!
    
    assert_equal 1, r.primary
    assert r.primary?
  
    r.unset_as_primary!
        
    assert_equal 0, r.primary
    assert !r.primary?
  
    # check valid values
    r.primary = 2
    assert !r.valid?
    assert_not_nil r.errors.on("primary")
  end

  def test_setup_done_and_deployed
    role = create_new_role(:stage => @stage , :host => @host)
    
    assert !role.setup_done?
    assert !role.deployed?
    assert_equal 'blank', role.status
    
    # create a failed setup deployment
    setup_deployment = create_new_deployment(:stage => @stage, :roles => [role], :task => 'deploy:setup', :success => 0)
    role.reload
    
    assert !role.setup_done?
    assert !role.deployed?
    assert_equal 'blank', role.status
    
    # create a succefull setup deployment
    setup_deployment = create_new_deployment(:stage => @stage, :roles => [role], :task => 'deploy:setup')
    setup_deployment.complete_successfully!
    role.reload
    
    assert role.setup_done?
    assert !role.deployed?
    assert_equal 'setup done', role.status
    
    # create a failed default deployment
    default_deployment = create_new_deployment(:stage => @stage, :roles => [role], :task => 'deploy:default', :success => 0)
    role.reload
    
    assert role.setup_done?
    assert !role.deployed?
    assert_equal 'setup done', role.status
    
    # create a succefull default deployment
    default_deployment = create_new_deployment(:stage => @stage, :roles => [role], :task => 'deploy:default')
    default_deployment.complete_successfully!
    role.reload
    
    assert role.setup_done?
    assert role.deployed?
    assert_equal 'deployed', role.status
  end
  
  def test_no_release
    role = create_new_role(:name => 'app')
    assert !role.no_release?
    
    role.no_release = 1
    
    assert role.no_release?
    
    role.unset_no_release!
    assert !role.no_release?
    
    role.set_no_release!
    assert role.no_release?
  end
  
  def test_role_attribute_hash
    role = create_new_role(:primary => 1, :no_release => 1)
    exp_res = {:no_release => true, :primary => true}
    assert_equal exp_res, role.role_attribute_hash
    
    role = create_new_role(:primary => 0, :no_release => 1)
    exp_res = {:no_release => true}
    assert_equal exp_res, role.role_attribute_hash
    
    role = create_new_role(:primary => 1, :no_release => 0)
    exp_res = {:primary => true}
    assert_equal exp_res, role.role_attribute_hash
    
    role = create_new_role(:primary => 0, :no_release => 0)
    exp_res = {}
    assert_equal exp_res, role.role_attribute_hash
  end
  
  def test_hostname_and_port
    host = create_new_host(:name => 'schaka.com')
    assert_equal 'schaka.com', host.name
    role = create_new_role(:host => host)
    
    assert_nil role.ssh_port
    assert_equal "schaka.com", role.hostname_and_port
    
    role.ssh_port = 2222    
    assert_equal "schaka.com:2222", role.hostname_and_port
    
    role.ssh_port = nil
    assert_equal "schaka.com", role.hostname_and_port
  end
  
  def test_custom_name
    host = create_new_host
    role = create_new_role(:host => host, :name => 'app')
    
    assert !role.custom_name?, "role '#{role.name}' not in #{Role::DEFAULT_NAMES.inspect}"
    
    role.name = 'jackhammer'
    assert role.custom_name?
    
    role.name = nil
    assert !role.custom_name?
  end
  
  def test_custom_name_validation
    host = create_new_host
    role = create_new_role(:host => host, :name => 'app')
    role.name = nil
    role.custom_name = 'michi'
    
    assert role.valid?, role.errors.inspect
    assert_equal 'michi', role.name
    
    role.save!
    
    # check custom_name after loading from DB
    db_role = Role.find(role.id)
    
    assert db_role.custom_name?
    assert_equal 'michi', db_role.name
    assert_equal 'michi', db_role.custom_name
  end
  
end
