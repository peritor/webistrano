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

$:.unshift "#{File.dirname(__FILE__)}/../../../lib"

require 'test/unit'
require 'net/ssh/service/process/driver'

class TC_Process_Driver < Test::Unit::TestCase

  class MockObject
    attr_reader :events

    def initialize
      @events = []
    end

    def method_missing( sym, *args, &block )
      token = [ sym, *args ]
      token << :with_block if block
      @events << token
      :return_value
    end

    undef_method :loop
  end

  def setup
    @connection = MockObject.new
    @log = MockObject.new
    @handlers = { :open => MockObject.new, :popen3 => MockObject.new }
    @driver = Net::SSH::Service::Process::Driver.new(
      @connection, @log, @handlers )
  end

  def test_open_no_block
    result = @driver.open( "foo" )
    assert_equal :return_value, result
    assert_equal [ [ :call, "foo" ] ], @handlers[:open].events
    assert_equal [], @connection.events
  end

  def test_open_block
    result = @driver.open( "foo" ) do |r|
      assert_equal :return_value, r
    end
    assert_nil result
    assert_equal [ [ :call, "foo" ] ], @handlers[:open].events
    assert_equal [ [ :loop ] ], @connection.events
  end

  def test_popen3_no_block
    result = @driver.popen3( "foo" )
    assert_equal :return_value, result
    assert_equal [ [ :popen3, "foo" ] ], @handlers[:popen3].events
    assert_equal [], @connection.events
  end

  def test_popen3_no_block
    result = @driver.popen3( "foo" ) { |f| }
    assert_equal :return_value, result
    assert_equal [ [ :popen3, "foo", :with_block ] ], @handlers[:popen3].events
    assert_equal [], @connection.events
  end

end
