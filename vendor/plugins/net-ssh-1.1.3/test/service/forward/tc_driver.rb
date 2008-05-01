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

require 'net/ssh/service/forward/driver'
require 'net/ssh/util/buffer'
require 'test/unit'
require 'socket'

class TC_Forward_Driver < Test::Unit::TestCase

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
    @handlers = { :local => MockObject.new, :remote => MockObject.new }

    @driver = Net::SSH::Service::Forward::Driver.new( @connection,
      Buffers.new, Log.new, @handlers )
  end

  def test_initialize
    assert_equal 0, @driver.direct_channel_count
    assert_equal 0, @driver.open_direct_channel_count
    assert_equal [ [ :add_channel_open_handler, [ "forwarded-tcpip" ], true ] ],
      @connection.events
  end

  def test_direct_channel
    handler = MockObject.new
    @driver.direct_channel( 1, "remote.host", 2, handler, 3, 4, 5 )

    assert_equal 1, @driver.direct_channel_count
    assert_equal 1, @driver.open_direct_channel_count

    assert_equal 2, @connection.events.length
    assert_equal [ :open_channel, [ "direct-tcpip",
      Net::SSH::Util::WriterBuffer.new(
        "\0\0\0\xbremote.host\0\0\0\2\0\0\0\x09127.0.0.1\0\0\0\1" ) ], true ],
      @connection.events.last
    assert_equal [ [ :on_confirm_failed, [], true ] ],
      @connection.returns.last.events

    channel = MockObject.new
    @connection.blocks.last.call( channel )

    assert_equal [ [ :method, [ :on_receive ], false ],
                   [ :method, [ :on_eof ], false ],
                   [ :confirm, [ channel, 1, "remote.host", 2, 3, 4, 5 ], false ],
                   [ :process, [ channel ], false ] ], handler.events

    assert_equal [ [ :on_data, [], true ],
                   [ :on_eof, [], true ],
                   [ :on_close, [], true ] ], channel.events

    channel.blocks.last.call( channel )
    assert_equal 0, @driver.open_direct_channel_count
    assert_equal [ :on_close, [ channel ], false ], handler.events.last
  end

  def test_local_bad_parm_count
    assert_raise( ArgumentError ) do
      @driver.local 1, 2
    end
    assert_raise( ArgumentError ) do
      @driver.local 1, 2, 3, 4, 5
    end
  end

  [
    [ :local_with_3, [ 12233, "test.host", 80 ] ],
    [ :local_with_4, [ "localhost", 12233, "test.host", 80 ] ]
  ].each do |name, args|
    define_method "test_#{name}" do
      assert_equal 0, @driver.open_direct_channel_count
      assert @driver.active_locals.empty?

      @driver.local(*args)

      address = '127.0.0.1'
      address = args.shift if args.first.is_a? String
      port = args.shift

      sleep 0.1
      socket = TCPSocket.new( address, port )
      sleep 0.1

      assert_equal 1, @driver.open_direct_channel_count
      assert !@driver.active_locals.empty?

      @driver.cancel_local( port, address )
      assert @driver.active_locals.empty?
    end
  end

  [
    [ :remote_with_2, [ 80 ] ],
    [ :remote_with_zero_port, [ 0 ] ],
    [ :remote_with_3, [ 80, 'localhost' ] ]
  ].each do |name, args|
    define_method "test_#{name}_success" do
      handler = MockObject.new

      port = args[0]
      host = args.last
      host = "127.0.0.1" unless host.is_a?( String )

      assert @driver.active_remotes.empty?
      assert_nothing_raised { @driver.remote( handler, *args ) }
      assert @driver.active_remotes.empty?

      assert_equal [ :global_request,
        [ "tcpip-forward", Net::SSH::Util::WriterBuffer.new(
          "\0\0\0#{host.length.chr}#{host}\0\0\0#{port.chr}" ) ], true ],
        @connection.events.last

      port = 0300 if port == 0
      response = Net::SSH::Util::ReaderBuffer.new( "\0\0\0#{port.chr}" )
      @connection.blocks.last.call( true, response )

      assert_equal [ port ], @driver.active_remotes

      assert_equal [ [ :setup, [ port ], false ] ], handler.events
    end

    define_method "test_#{name}_fail_handled" do
      handler = MockObject.new

      port = args[0]
      host = args.last
      host = "127.0.0.1" unless host.is_a?( String )

      assert @driver.active_remotes.empty?
      assert_nothing_raised { @driver.remote( handler, *args ) }
      assert @driver.active_remotes.empty?

      @connection.blocks.last.call( false, nil )

      assert_equal [ [ :error, [ "remote port #{port} could not be forwarded to local host" ], false ] ], handler.events
    end

    define_method "test_#{name}_fail_unhandled" do
      port = args[0]
      host = args.last
      host = "127.0.0.1" unless host.is_a?( String )

      assert @driver.active_remotes.empty?
      assert_nothing_raised { @driver.remote( nil, *args ) }
      assert @driver.active_remotes.empty?

      assert_raise( Net::SSH::Exception ) do
        @connection.blocks.last.call( false, nil )
      end
    end

    define_method "test_#{name}_duplicate" do
      handler = MockObject.new
      port = args[0]
      port = 0300 if port == 0
      @driver.remote( handler, *args )
      response = Net::SSH::Util::ReaderBuffer.new( "\0\0\0#{port.chr}" )
      @connection.blocks.last.call( true, response )

      args = args.dup
      args[0] = port
      assert_raise( Net::SSH::Exception ) do
        @driver.remote( handler, *args )
      end
    end
  end

  def test_remote_to
    @driver.remote_to( 1, "test.host", 2 )
    assert_equal [ [ :call, [ 1, "test.host" ], false ] ],
      @handlers[:remote].events
  end

  def test_cancel_remote_success
    @driver.remote_to( 1, "test.host", 2 )
    @connection.blocks.last.call( true, nil )
    assert_equal 1, @driver.active_remotes.length

    @driver.cancel_remote( 2 )
    assert_equal [ :global_request, [ "cancel-tcpip-forward",
      Net::SSH::Util::WriterBuffer.new( "\0\0\0\x09127.0.0.1\0\0\0\2" ) ],
      true ], @connection.events.last

    @connection.blocks.last.call( true, nil )
    assert_equal 0, @driver.active_remotes.length
  end

  def test_cancel_remote_failure
    @driver.remote_to( 1, "test.host", 2 )
    @connection.blocks.last.call( true, nil )
    assert_equal 1, @driver.active_remotes.length

    @driver.cancel_remote( 2 )
    assert_raise( Net::SSH::Exception ) do
      @connection.blocks.last.call( false, nil )
    end
  end

  def test_do_open_channel_valid
    handler = MockObject.new
    @driver.remote( handler, 80 )
    @connection.blocks.last.call( true, nil )
    assert_equal 1, @driver.active_remotes.length

    channel = MockObject.new
    data = Net::SSH::Util::ReaderBuffer.new(
      "\0\0\0\017123.456.789.012\0\0\0\120\0\0\0\017345.678.901.234\0\0\0\2" )

    @driver.do_open_channel( @connection, channel, data )

    assert_equal [
      [ :on_open, [ channel, "123.456.789.012", 80, "345.678.901.234", 2 ], false ],
      [ :method, [ :on_receive ], false ],
      [ :method, [ :on_close ], false ],
      [ :method, [ :on_eof ], false ] ], handler.events[1..-1]

    assert_equal [
      [ :on_data, [], true ],
      [ :on_close, [], true ],
      [ :on_eof, [], true ] ], channel.events
  end

  def test_do_open_channel_invalid
    handler = MockObject.new
    channel = MockObject.new
    data = Net::SSH::Util::ReaderBuffer.new(
      "\0\0\0\017123.456.789.012\0\0\0\120\0\0\0\017345.678.901.234\0\0\0\2" )

    assert_raise( Net::SSH::Exception ) do
      @driver.do_open_channel( @connection, channel, data )
    end
  end

end
