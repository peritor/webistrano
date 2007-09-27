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
require 'net/ssh/service/process/popen3'

class TC_Process_POpen3 < Test::Unit::TestCase

  class MockObject
    attr_reader :events

    def initialize
      @events = []
    end

    def method_missing( sym, *args, &block )
      token = [ sym, *args ]
      token << :with_block if block
      @events << token
    end

    undef_method :loop
  end

  class Channel < MockObject
    attr_reader :connection

    def connection
      @connection ||= MockObject.new
    end
  end

  class TC_SSHStdinPipe < Test::Unit::TestCase
    def setup
      @channel = Channel.new
      @pipe = Net::SSH::Service::Process::POpen3Manager::SSHStdinPipe.new(
        @channel )
    end

    def test_write
      @pipe.write "foo"
      assert_equal [ [ :send_data, "foo" ] ], @channel.events
    end

    def test_puts_nonl
      @pipe.puts "foo"
      assert_equal [ [ :send_data, "foo\n" ] ], @channel.events
    end

    def test_puts_nl
      @pipe.puts "foo\n"
      assert_equal [ [ :send_data, "foo\n" ] ], @channel.events
    end
  end

  class TC_SSHStdoutPipe < Test::Unit::TestCase
    def setup
      @channel = Channel.new
      @pipe = Net::SSH::Service::Process::POpen3Manager::SSHStdoutPipe.new(
        @channel )
    end

    def test_read_empty
      klass = class << @channel.connection; self; end
      pipe = @pipe
      klass.send(:define_method,:process) { pipe.instance_variable_set( :@data, "foo" ) }
      s = @pipe.read
      assert_equal "foo", s
    end

    def test_read_full
      @pipe.do_data @channel, "foo"
      s = @pipe.read
      assert_equal "foo", s
      assert_equal [], @channel.connection.events
    end
  end

  class TC_SSHStderrPipe < Test::Unit::TestCase
    def setup
      @channel = Channel.new
      @pipe = Net::SSH::Service::Process::POpen3Manager::SSHStderrPipe.new(
        @channel )
    end

    def test_read_empty
      klass = class << @channel.connection; self; end
      pipe = @pipe
      klass.send(:define_method,:process) do
        data = pipe.instance_variable_get( :@data )
        pipe.instance_variable_set( :@data, (data||"") + "foo" )
      end
      s = @pipe.read
      assert_equal "foo", s
    end

    def test_read_stderr
      @pipe.do_data @channel, 1, "foo"
      s = @pipe.read
      assert_equal "foo", s
      assert_equal [], @channel.connection.events
    end
  end

  class Connection < MockObject
    class Channel < MockObject
      attr_reader :success
      attr_reader :failure

      def on_success( &block )
        super
        @success = block
      end

      def on_failure( &block )
        super
        @failure = block
      end
    end

    attr_reader :channel
    def open_channel( type )
      super
      yield @channel = Channel.new
    end
  end

  def test_popen3
    conn = Connection.new
    mgr = Net::SSH::Service::Process::POpen3Manager.new( conn, nil )
    mgr.popen3( "foo" ) do |a,b,c|
      assert_instance_of(
        Net::SSH::Service::Process::POpen3Manager::SSHStdinPipe, a )
      assert_instance_of(
        Net::SSH::Service::Process::POpen3Manager::SSHStdoutPipe, b )
      assert_instance_of(
        Net::SSH::Service::Process::POpen3Manager::SSHStderrPipe, c )
    end

    assert_equal [ [ :open_channel, "session", :with_block ],
      [ :loop ] ], conn.events
    chan = conn.channel
    assert_equal [ [ :on_success, :with_block ],
      [ :on_failure, :with_block ], [ :exec, "foo", true ] ], chan.events

    chan.success.call( chan )
  end

end
