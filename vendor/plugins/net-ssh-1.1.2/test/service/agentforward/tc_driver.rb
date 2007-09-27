#--
# =============================================================================
# Copyright (c) 2007, Chris Andrews (chris@nodnol.org),
#   Jamis Buck (jgb3@email.byu.edu)
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

require 'net/ssh/service/agentforward/driver'
require 'net/ssh/util/buffer'
require 'test/unit'
require 'socket'

class TC_AgentForward_Driver < Test::Unit::TestCase

  class Net::SSH::Service::AgentForward::Driver
    attr_reader :data
  end

  class Buffers
    def writer
      Net::SSH::Util::WriterBuffer.new
    end
  end

  class Log
    def debug?
      true
    end
    def debug(msg)
    end
  end

  class Agent
    attr_reader :sends
    def initialize
      @sends = []
    end
    def read_raw_packet
      "raw agent data"
    end
    def send_raw_packet(data)
      @sends.push data
    end
  end

  class MockObject
    attr_reader :events
    attr_reader :blocks
    attr_reader :returns

    def initialize
      @events = []
      @blocks = []
      @returns = []
    end
    def method_missing( sym, *args, &block )
      @blocks << block
      @events << [ sym, args, !block.nil? ]
      @returns << MockObject.new
      @returns.last
    end
    def method( sym )
      @events << [ :method, [ sym ], false ]
      lambda { || }
    end
    def respond_to?( sym )
      true
    end
  end

  def setup
    @connection = MockObject.new
    @agent = Agent.new

    @driver = Net::SSH::Service::AgentForward::Driver.new( @connection,
      Buffers.new, Log.new, @agent )
  end

  def test_initialize
    assert_equal [ [:add_channel_open_handler, [ "auth-agent@openssh.com" ], true] ],
      @connection.events
  end
  
  def test_request
    @driver.request
    assert_equal 2, @connection.events.length
    assert_equal [:channel_request, ["auth-agent-req@openssh.com"], false],
      @connection.events[1]
  end

  def test_do_open_channel
    connection = MockObject.new
    channel = MockObject.new
    @driver.do_open_channel(connection, channel, nil)
    assert_equal [ [:on_data, [], true] ],
      channel.events
  end

  def test_do_data_complete_packet
    channel = MockObject.new
    data = "\000\000\000\001v"
    @driver.do_data(channel, data)
    assert_equal [ [:send_data, ["raw agent data"], false ] ],
      channel.events
    assert_equal [ data ],
      @agent.sends
    assert_equal '', @driver.data
  end

  def test_do_data_incomplete_packet
    channel = MockObject.new

    @driver.do_data(channel, "\000\000\000\001")
    assert_equal 0, channel.events.length
    assert_equal 0, @agent.sends.length
    assert_equal @driver.data, "\000\000\000\001"

    @driver.do_data(channel, "v")
    assert_equal [ [:send_data, ["raw agent data"], false ] ],
      channel.events
    assert_equal [ "\000\000\000\001v" ],
      @agent.sends
    assert_equal '', @driver.data
  end

end
