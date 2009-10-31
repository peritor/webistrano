require File.dirname(__FILE__) + '/../test_helper'

class HostTest < ActiveSupport::TestCase
  
  def setup
    Host.delete_all
  end

  def test_creation
    assert_equal 0, Host.count
    
    assert_nothing_raised{
      h = Host.create!(:name => "test.example.com") 
    }
    
    assert_equal 1, Host.count
  end
  
  def test_validation
    h = Host.create!(:name => "192.168.0.1")
    
    # try to create another host with the same name
    h = Host.new(:name => "192.168.0.1")
    assert !h.valid?
    assert_not_nil h.errors.on("name")
    
    # try to create a host with a name that is too long
    name = "com." * 251
    name = name.chop
    h = Host.new(:name => name)
    assert !h.valid?
    assert_not_nil h.errors.on("name")
    
    # make it pass
    name = "example.com"
    h = Host.new(:name => name)
    assert h.valid?
  end
  
  def test_validation_of_name_if_ip
    # some valid IPs
    assert valid_host_name('192.168.0.1  ')
    assert valid_host_name(' 192.168.0.110')
  end
  
  def test_validation_of_name_if_domain_name
    assert valid_host_name('map.example.com')
    assert valid_host_name('web12.example.com')
    assert valid_host_name('localhost')
    
    # some invalid domains
    assert invalid_host_name('mail:example.com')
    assert invalid_host_name('mail*.#.example.com')
  end
  
  def test_stages
    host = create_new_host
    
    stage_1 = create_new_stage
      role_1 = create_new_role(:name => 'web', :stage => stage_1, :host => host)
      role_2 = create_new_role(:name => 'app', :stage => stage_1, :host => host)
      
    stage_2 = create_new_stage
      role_3 = create_new_role(:name => 'web', :stage => stage_2, :host => host)
      role_4 = create_new_role(:name => 'app', :stage => stage_2, :host => host)  
      
    assert_equal 4, host.roles.count
    assert_equal 2, host.stages.uniq.size # XXX pure count does not work!!!
    assert_equal [stage_1.id, stage_2.id].sort, host.stages.collect(&:id).sort
    
    assert_equal [host], stage_1.hosts
    assert_equal [host], stage_2.hosts
  end
  
  
  # helper functions
  
  def valid_host_name(name)
    h = Host.new
    h.name = name
    h.valid?
  end
  
  def invalid_host_name(name)
    !valid_host_name(name)
  end
  
end
