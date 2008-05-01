#--
# =============================================================================
# Copyright (c) 2004,2005 Jamis Buck (jamis@37signals.com)
# All rights reserved.
#
# This source file is distributed as part of the Net::SSH Secure Shell Client
# library for Ruby. This file (and the library as a whole) may be used only as
# allowed by either the BSD license, or the Ruby license (or, by association
# with the Ruby license, the GPL). See the "doc" subdirectory of the Net::SSH
# distribution for the texts of these licenses.
# -----------------------------------------------------------------------------
# net-ssh website : http://net-ssh.rubyforge.org
# project website: http://rubyforge.org/projects/net-ssh
# =============================================================================
#++

$:.unshift "#{File.dirname(__FILE__)}/../../lib"

require 'net/ssh/userauth/userkeys'
require 'net/ssh/util/buffer'
require 'test/unit'
require 'logger'
require 'stringio'

class TC_UserKeyManager < Test::Unit::TestCase

  class Buffers
    def writer
      Net::SSH::Util::WriterBuffer.new
    end
  end

  class Keys
    def load_public_key( file )
      o = Object.new
      singleton = class << o; self; end
      singleton.send( :define_method, :ssh_type ) { "test" }
      o
    end

    def load_private_key( file )
      count = 0
      o = Object.new
      singleton = class << o; self; end
      singleton.send( :define_method, :ssh_do_sign ) { |data| count += 1; "<#{data}:#{count}>" }
      o
    end
  end

  class AgentFactory
    attr_reader :state

    def initialize
      @state = :new
    end

    def open
      @state = :opened
      self
    end

    def sign( identity, data )
      "from the agent (#{identity.inspect}, #{data.inspect})"
    end

    def identities
      [ :one, :two, :three ]
    end

    def close
      @state = :closed
    end
  end

  class ExistenceTester
    def readable?( file )
      true
    end
  end

  def setup
    @userkeys = Net::SSH::UserAuth::UserKeyManager.new
    @userkeys.agent_factory = @agent_factory = AgentFactory.new
    @userkeys.keys = Keys.new
    @userkeys.log = @log = Logger.new( StringIO.new )
    @userkeys.buffers = Buffers.new
    @userkeys.key_existence_tester = ExistenceTester.new
  end

  def test_initialize
    assert_equal 0, @userkeys.key_files.length
    assert_equal 0, @userkeys.host_key_files.length
    assert @userkeys.use_agent?
  end

  def test_add
    assert_equal 0, @userkeys.key_files.length
    @userkeys.add "hello"
    assert_equal 1, @userkeys.key_files.length
    assert_equal "hello", @userkeys.key_files.first
    @userkeys.add "world"
    assert_equal 2, @userkeys.key_files.length
    @userkeys.add "hello"
    assert_equal 2, @userkeys.key_files.length
  end

  def test_add_host_key
    assert_equal 0, @userkeys.host_key_files.length
    @userkeys.add_host_key "hello"
    assert_equal 1, @userkeys.host_key_files.length
    assert_equal "hello", @userkeys.host_key_files.first
    @userkeys.add_host_key "world"
    assert_equal 2, @userkeys.host_key_files.length
    @userkeys.add_host_key "hello"
    assert_equal 2, @userkeys.host_key_files.length
  end

  def test_clear!
    @userkeys.add "hello"
    @userkeys.add "howdy"
    assert_equal 2, @userkeys.key_files.length
    @userkeys.clear!
    assert_equal 0, @userkeys.key_files.length
  end

  def test_clear_host!
    @userkeys.add_host_key "hello"
    @userkeys.add_host_key "howdy"
    assert_equal 2, @userkeys.host_key_files.length
    @userkeys.clear_host!
    assert_equal 0, @userkeys.host_key_files.length
  end

  def test_clear_and_clear_host!
    @userkeys.add "hello"
    @userkeys.add "howdy"
    @userkeys.add_host_key "hello"
    @userkeys.add_host_key "howdy"
    assert_equal 2, @userkeys.key_files.length
    assert_equal 2, @userkeys.host_key_files.length
    @userkeys.clear!
    assert_equal 0, @userkeys.key_files.length
    assert_equal 2, @userkeys.host_key_files.length
    @userkeys.add "hello"
    @userkeys.add "howdy"
    assert_equal 2, @userkeys.key_files.length
    assert_equal 2, @userkeys.host_key_files.length
    @userkeys.clear_host!
    assert_equal 2, @userkeys.key_files.length
    assert_equal 0, @userkeys.host_key_files.length
  end

  def test_finish_use_agent_unopened
    @userkeys.use_agent = true
    assert_equal :new, @agent_factory.state
    @userkeys.finish
    assert_equal :new, @agent_factory.state
  end

  def test_finish_unopened_no_use_agent
    @userkeys.use_agent = false
    assert_equal :new, @agent_factory.state
    @userkeys.finish
    assert_equal :new, @agent_factory.state
  end

  def test_finish_use_agent_opened
    @userkeys.use_agent = true
    @userkeys.identities
    assert_equal :opened, @agent_factory.state
    @userkeys.finish
    assert_equal :closed, @agent_factory.state
  end

  def test_finish_no_use_agent_opened
    @userkeys.use_agent = false
    @userkeys.identities
    assert_equal :new, @agent_factory.state
    @userkeys.finish
    assert_equal :new, @agent_factory.state
  end

  def test_identities_no_use_agent_no_files
    @userkeys.use_agent = false
    ids = @userkeys.identities
    assert_equal 0, ids.length
  end

  def test_identities_use_agent_no_files
    @userkeys.use_agent = true
    ids = @userkeys.identities
    assert_equal 3, ids.length
  end

  def test_identities_no_use_agent_files
    @userkeys.use_agent = false
    @userkeys.add "one"
    @userkeys.add "two"
    @userkeys.add "three"
    ids = @userkeys.identities
    assert_equal 3, ids.length
  end

  def test_identities_use_agent_files
    @userkeys.use_agent = true
    @userkeys.add "one"
    @userkeys.add "two"
    @userkeys.add "three"
    ids = @userkeys.identities
    assert_equal 6, ids.length
  end

  def test_host_identities_no_files
    ids = @userkeys.host_identities
    assert_equal 0, ids.length
  end

  def test_host_identities_files
    @userkeys.add_host_key "one"
    @userkeys.add_host_key "two"
    @userkeys.add_host_key "three"
    ids = @userkeys.host_identities
    assert_equal 3, ids.length
  end

  def test_sign_from_file
    @userkeys.use_agent = false
    @userkeys.add "one"
    ids = @userkeys.identities
    assert_equal 1, ids.length
    data = @userkeys.sign( ids.first, "hello" )
    assert_equal "\0\0\0\4test\0\0\0\11<hello:1>", data
  end

  def test_sign_from_agent
    @userkeys.use_agent = true
    ids = @userkeys.identities
    assert_equal 3, ids.length
    data = @userkeys.sign( ids.first, "hello" )
    assert_equal %q{from the agent (:one, "hello")}, data
  end

  def test_sign_from_key
    @userkeys.use_agent = false
    @userkeys.add "one"
    ids = @userkeys.identities
    assert_equal 1, ids.length
    @userkeys.sign( ids.first, "hello" )
    data = @userkeys.sign( ids.first, "hello" )
    assert_equal "\0\0\0\4test\0\0\0\11<hello:2>", data
  end

  def test_use_agent
    assert @userkeys.use_agent?
    @userkeys.identities
    assert_equal :opened, @agent_factory.state
    @userkeys.use_agent = false
    assert_equal :closed, @agent_factory.state
    @userkeys.use_agent = true
    assert_equal :closed, @agent_factory.state
    @userkeys.identities
    assert_equal :opened, @agent_factory.state
  end

end
