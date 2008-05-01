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
require 'net/ssh/service/process/open'

class TC_Process_Open < Test::Unit::TestCase

  class Log
    def debug?
      true
    end

    def debug(msg)
    end
  end

  class MockObject
    attr_reader :events

    def initialize
      @events = []
    end

    def method_missing( sym, *args, &block )
      token = [ sym, *args ]
      token << true if block
      @events << token
    end
  end

  class Connection < MockObject
    attr_reader :channel

    def open_channel( *args, &block )
      @events << [ :open_channel, *args ] + [ block ? true : false ]
      @channel = MockObject.new
    end
  end

  def create_manager( &block )
    connection = Connection.new
    mgr = Net::SSH::Service::Process::OpenManager.new( connection,
      Log.new, "test", &block )
    [ mgr, connection ]
  end

  def test_no_block
    mgr, conn = create_manager
    assert_equal [ [ :open_channel, "session", true ] ], conn.events
  end

  def test_with_block
    yielded = false
    mgr, conn = create_manager { |mgr| yielded = true }
    assert_equal [ [ :open_channel, "session", true ],
                   [ :loop ] ], conn.events
    assert yielded
  end

  def test_write
    mgr, conn = create_manager
    mgr.write "foo"
    assert_equal [ [ :send_data, "foo" ] ], conn.channel.events
  end

  def test_puts_nonl
    mgr, conn = create_manager
    mgr.puts "foo"
    assert_equal [ [ :send_data, "foo\n" ] ], conn.channel.events
  end

  def test_puts_nl
    mgr, conn = create_manager
    mgr.puts "foo\n"
    assert_equal [ [ :send_data, "foo\n" ] ], conn.channel.events
  end

  def test_close_input
    mgr, conn = create_manager
    mgr.close_input
    assert_equal [ [ :send_eof ] ], conn.channel.events
  end

  def test_close
    mgr, conn = create_manager
    mgr.close
    assert_equal [ [ :close ] ], conn.channel.events
  end

  def test_confirm
    mgr, conn = create_manager
    chan = MockObject.new
    mgr.do_confirm chan
    assert_equal [ [ :on_success, true ], [ :on_failure, true ],
                   [ :exec, "test", true ] ], chan.events
  end

  def test_exec_success
    mgr, conn = create_manager
    chan = MockObject.new
    called = false
    mgr.on_success { |ch| called = true }
    mgr.do_exec_success chan
    assert_equal [ [ :on_data, true ], [ :on_extended_data, true ],
                   [ :on_close, true ], [ :on_request, true ] ], chan.events
    assert called
  end

  def test_exec_failure_no_callback
    mgr, conn = create_manager
    chan = MockObject.new
    assert_raise( Net::SSH::Exception ) do
      mgr.do_exec_failure chan
    end
  end

  def test_exec_failure_callback
    mgr, conn = create_manager
    chan = MockObject.new
    called = false
    mgr.on_failure { |ch,msg| called = true }
    mgr.do_exec_failure chan
    assert called
  end

  def test_stdout
    mgr, conn = create_manager
    chan = MockObject.new
    data = ""
    mgr.on_stdout { |ch,d| data = d }
    mgr.do_data chan, "foo"
    assert_equal "foo", data
  end

  def test_extended_data_not_stderr
    mgr, conn = create_manager
    chan = MockObject.new
    data = ""
    mgr.on_stderr { |ch,d| data = d }
    mgr.do_extended_data chan, 0, "foo"
    assert_equal "", data
  end

  def test_extended_data_stderr
    mgr, conn = create_manager
    chan = MockObject.new
    data = ""
    mgr.on_stderr { |ch,d| data = d }
    mgr.do_extended_data chan, 1, "foo"
    assert_equal "foo", data
  end

  def test_close
    mgr, conn = create_manager
    chan = MockObject.new
    called = false
    mgr.on_exit { |ch,status| called = true }
    mgr.do_close chan
    assert called
    assert_equal [], chan.events
  end

end
