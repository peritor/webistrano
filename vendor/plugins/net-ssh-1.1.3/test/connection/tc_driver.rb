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
require 'net/ssh/connection/driver'
require 'net/ssh/errors'
require 'net/ssh/util/buffer'

class TC_Driver < Test::Unit::TestCase

  class Buffers
    def writer
      Net::SSH::Util::WriterBuffer.new
    end
  end

  class Log
    attr_reader :messages

    def initialize
      @messages = []
    end

    def debug?
      true
    end

    def debug( msg )
      @messages << msg
    end
  end

  class Session
    attr_reader :events
    attr_reader :script

    def initialize
      @events = []
      @script = []
    end

    def send_message( msg )
      @events << msg.to_s
    end

    def wait_for_message
      @script.shift
    end
  end

  class Channel
    attr_reader :local_id
    attr_reader :remote_id
    attr_reader :data
    attr_reader :window_size
    attr_reader :packet_size
    attr_reader :type
    attr_reader :block
    attr_reader :events

    def self.open( type, data )
      new( type, data, nil, nil, nil )
    end

    def self.create( type, remote_id, window_size, packet_size )
      new( type, nil, remote_id, window_size, packet_size )
    end

    def initialize( type, data, remote_id, winsize, packsize )
      @type = type
      @data = data
      @remote_id = remote_id
      @window_size = winsize
      @packet_size = packsize
      @local_id = 1
      @events = []
    end

    def close( value )
      @events << [ :close, value ]
    end

    def on_confirm_open( &block )
      @block = block
    end

    def self.event( name )
      define_method( "do_#{name}".to_sym ) do |*args|
        @events << [ name, *args ]
      end
    end

    event :confirm_failed
    event :confirm_open
    event :window_adjust
    event :data
    event :extended_data
    event :eof
    event :request
    event :success
    event :failure
  end

  def reader( text )
    Net::SSH::Util::ReaderBuffer.new( text )
  end

  def setup
    @session = Session.new
    @log = Log.new
    @driver = Net::SSH::Connection::Driver.new( @session, @log,
      Buffers.new,
      :open => proc { |t,d| Channel.open(t,d) },
      :create => proc { |t,r,w,p| Channel.create(t,r,w,p) } )
  end

  def test_open_channel
    channel = @driver.open_channel( "test", "data" ) { |a| a }
    assert_equal "hello", channel.block.call( "hello" )
    assert_equal "test", channel.type
    assert_equal "data", channel.data
    assert_equal [ channel ], @driver.channels
  end

  def test_remove_channel
    channel = @driver.open_channel( "test", "data" ) { |a| a }
    assert_equal [channel], @driver.channels
    @driver.remove_channel( channel )
    assert_equal [], @driver.channels
  end

  def test_allocate_channel_id
    assert_equal 1, @driver.allocate_channel_id
    10.times { @driver.allocate_channel_id }
    assert_equal 12, @driver.allocate_channel_id
  end

  def test_global_request
    @driver.global_request "test", "foobar"
    assert_equal [ "\120\0\0\0\4test\1foobar" ], @session.events
  end

  def test_request_success
    @driver.global_request( "test", "foobar" ) do |a,b|
      assert a
      assert_equal "response", b
    end

    @driver.do_request_success "response"
  end

  def test_request_failure
    @driver.global_request( "test", "foobar" ) do |a,b|
      assert !a
      assert_equal "response", b
    end

    @driver.do_request_failure "response"
  end

  def test_channel_open_no_handler
    assert_raise( Net::SSH::Exception ) do
      @driver.do_channel_open(
        reader( "\0\0\0\4test\0\0\0\4\0\0\0\0\0\0\0\1" ) )
    end
  end

  def test_channel_open_with_handler
    @driver.add_channel_open_handler( "test" ) do |conn,chan,resp|
      assert_equal @driver, conn
      assert_equal "test", chan.type
      assert_equal 4, chan.remote_id
      assert_equal 0, chan.window_size
      assert_equal 1, chan.packet_size
      assert_equal "hello world", resp.read
    end

    @driver.do_channel_open(
      reader( "\0\0\0\4test\0\0\0\4\0\0\0\0\0\0\0\1hello world" ) )

    assert_equal 1, @driver.channels.length
    assert_equal [ "\133\0\0\0\4\0\0\0\1\x7f\xff\xff\xff\x7f\xff\xff\xff" ],
      @session.events
  end

  def test_channel_open_failure
    channel = @driver.open_channel( "test", "data" )
    assert_equal 1, @driver.channels.length
    @driver.do_channel_open_failure(
      reader( "\0\0\0\1\0\0\0\2\0\0\0\4test\0\0\0\2en" ) )
    assert_equal 0, @driver.channels.length
    assert_equal [ [ :confirm_failed, 2, "test", "en" ] ], channel.events
  end

  def test_channel_open_confirmation
    channel = @driver.open_channel( "test", "data" )
    @driver.do_channel_open_confirmation(
      reader( "\0\0\0\1\0\0\0\2\0\0\0\3\0\0\0\4" ) )
    assert_equal 1, @driver.channels.length
    assert_equal [ [ :confirm_open, 2, 3, 4 ] ], channel.events
  end

  def test_channel_window_adjust
    channel = @driver.open_channel( "test", "data" )
    @driver.do_channel_window_adjust( reader( "\0\0\0\1\0\0\0\12" ) )
    assert_equal 1, @driver.channels.length
    assert_equal [ [ :window_adjust, 10 ] ], channel.events
  end

  def test_channel_data
    channel = @driver.open_channel( "test", "data" )
    @driver.do_channel_data( reader( "\0\0\0\1\0\0\0\4test" ) )
    assert_equal 1, @driver.channels.length
    assert_equal [ [ :data, "test" ] ], channel.events
  end

  def test_channel_extended_data
    channel = @driver.open_channel( "test", "data" )
    @driver.do_channel_extended_data( reader( "\0\0\0\1\0\0\0\2\0\0\0\4test" ) )
    assert_equal 1, @driver.channels.length
    assert_equal [ [ :extended_data, 2, "test" ] ], channel.events
  end

  def test_channel_eof
    channel = @driver.open_channel( "test", "data" )
    @driver.do_channel_eof( reader( "\0\0\0\1" ) )
    assert_equal 1, @driver.channels.length
    assert_equal [ [ :eof ] ], channel.events
  end

  def test_channel_close
    channel = @driver.open_channel( "test", "data" )
    @driver.do_channel_close( reader( "\0\0\0\1" ) )
    assert_equal 1, @driver.channels.length
    assert_equal [ [ :close, false ] ], channel.events
  end

  def test_channel_request
    channel = @driver.open_channel( "test", "data" )
    @driver.do_channel_request( reader( "\0\0\0\1\0\0\0\4test\1foobarbaz" ) )
    assert_equal 1, @driver.channels.length
    assert_equal [ [ :request, "test", true, reader("foobarbaz") ] ],
      channel.events
  end

  def test_channel_success
    channel = @driver.open_channel( "test", "data" )
    @driver.do_channel_success( reader( "\0\0\0\1" ) )
    assert_equal 1, @driver.channels.length
    assert_equal [ [ :success ] ], channel.events
  end

  def test_channel_failure
    channel = @driver.open_channel( "test", "data" )
    @driver.do_channel_failure( reader( "\0\0\0\1" ) )
    assert_equal 1, @driver.channels.length
    assert_equal [ [ :failure ] ], channel.events
  end

  ProcessItem = Struct.new( :name, :script, :events )
  def self.i( name, script, events )
    ProcessItem.new( name, script, events )
  end

  def test_process_bad
    @session.script << [ 0, reader("") ]
    assert_raise( Net::SSH::Exception ) do
      @driver.process
    end
  end

end
