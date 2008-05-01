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

require 'net/ssh/service/forward/local-network-handler'
require 'test/unit'

class TC_LocalNetworkHandler < Test::Unit::TestCase

  class Log
    def debug?
      true
    end

    def debug( msg )
    end

    def error( msg )
    end
  end

  class Client
    attr_reader :events
    attr_reader :script

    def initialize
      @events = []
      @script = []
    end

    def send( data, code )
      @events << [ :send, data, code ]
    end

    def recv( block_size )
      @events << [ :recv, block_size ]
      @script.shift
    end
  end

  class Channel
    attr_reader :events

    def initialize
      @values = Hash.new
      @events = []
    end

    def []( name )
      @values[name]
    end

    def []=( name, value )
      @values[name] = value
    end

    def close
      @events << :close
    end

    def send_data( data )
      @events << data
    end
  end

  def setup
    @client = Client.new
    @channel = Channel.new
    @handler = Net::SSH::Service::Forward::LocalNetworkHandler.new(
      Log.new, 16, @client )
  end

  def test_on_receive
    @handler.on_receive( @channel, "hello" )
    assert_equal [ [ :send, "hello", 0 ] ], @client.events
  end

  def test_on_eof
    assert !@channel[:eof]
    @handler.on_eof( @channel )
    assert @channel[:eof]
  end

  def test_process_no_eof
    @client.script << "part 1"
    @client.script << "part 2"
    @client.script << "part 3"

    @handler.process @channel

    assert_equal [ "part 1", "part 2", "part 3", :close ], @channel.events
    assert_equal [ [ :recv, 16 ], [ :recv, 16 ], [ :recv, 16 ], [ :recv, 16 ] ],
      @client.events
  end

  def test_process_eof
    @channel[:eof] = true
    @handler.process @channel
    assert_equal [ :close ], @channel.events
    assert_equal [], @client.events
  end

  def test_process_error
    assert_nothing_raised do
      @handler.process nil
    end
  end

end
