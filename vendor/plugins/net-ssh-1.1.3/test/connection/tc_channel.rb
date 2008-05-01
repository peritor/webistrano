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

require 'test/unit'
require 'net/ssh/connection/channel'
require 'net/ssh/util/buffer'

class TC_Channel < Test::Unit::TestCase

  class Buffers
    def writer
      Net::SSH::Util::WriterBuffer.new
    end
  end

  class Log
    def debug?
      false
    end
  end

  class Connection
    attr_reader :buffers
    attr_reader :events

    def initialize( buffers )
      @events = []
      @buffers = buffers
    end

    def send_message( msg )
      @events << msg.to_s
    end

    def allocate_channel_id
      events << :allocate_channel_id
      1234
    end

    def remove_channel( channel )
      events << :remove_channel
    end
  end

  def setup
    @connection = Connection.new( Buffers.new )
  end

  def test_open_no_data
    channel = Net::SSH::Connection::Channel.open( @connection, Log.new,
      Buffers.new, "test" )
    assert_equal [ :allocate_channel_id,
      "\132\0\0\0\4test\0\0\4\xd2\x00\x02\x00\x00\x00\x01\x00\x00" ],
      @connection.events
    assert_equal "test", channel.type
  end

  def test_open_with_data
    channel = Net::SSH::Connection::Channel.open( @connection, Log.new,
      Buffers.new, "test", "some data" )
    assert_equal [ :allocate_channel_id,
      "\132\0\0\0\4test\0\0\4\xd2\x00\x02\x00\x00\x00\x01\x00\x00some data" ],
      @connection.events
    assert_equal "test", channel.type
  end

  def test_do_confirm_open
    confirmed = nil
    channel = Net::SSH::Connection::Channel.open( @connection, Log.new,
      Buffers.new, "test" )
    channel.on_confirm_open { |a| confirmed = a }
    channel.do_confirm_open 1, 2, 3
    assert_same channel, confirmed
    assert_equal 1, channel.remote_id
    assert_equal 2, channel.window_size
    assert_equal 3, channel.maximum_packet_size
  end

  def create_channel
    Net::SSH::Connection::Channel.create( @connection, Log.new, Buffers.new,
      "test", 1, 2, 3 )
  end

  def test_create
    channel = create_channel
    assert_equal "test", channel.type
    assert_equal [ :allocate_channel_id ], @connection.events
    assert_equal 1234, channel.local_id
    assert_equal 1, channel.remote_id
    assert_equal 2, channel.window_size
    assert_equal 3, channel.maximum_packet_size
  end

  def test_new
    assert_raise( NoMethodError ) do
      Net::SSH::Connection::Channel.new( @connection, "test" )
    end
  end

  def self.test_callback( name, do_args=[], expect=do_args )
    define_method( "test_#{name}".to_sym ) do
      channel = create_channel

      result = nil
      channel.send( "on_#{name}".to_sym ) { |*a| result = a }
      channel.send( "do_#{name}".to_sym, *do_args )

      assert_equal [ channel, *expect ], result
    end
  end

  test_callback :confirm_open, [ 1, 2, 3 ], []
  test_callback :confirm_failed, [ 100, "b", "c" ]
  test_callback :window_adjust, [ 14 ]
  test_callback :data, [ "blah" ]
  test_callback :extended_data, [ 1, "blah" ]
  test_callback :eof
  test_callback :request, [ true, "blah" ]
  test_callback :success
  test_callback :failure
end
