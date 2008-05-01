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

require 'net/ssh/service/forward/remote-network-handler'
require 'test/unit'
require 'socket'

class TC_RemoteNetworkHandler < Test::Unit::TestCase

  class Log
    def debug?
      true
    end

    def debug( msg )
    end

    def error( msg )
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

  HOST = "127.0.0.1"
  PORT = 12248

  class ScriptedServer
    attr_reader :script

    def initialize
      @script = []
      @thread = Thread.new {
        server = TCPServer.new( HOST, PORT )
        client = server.accept
        until @script.empty?
          client.send @script.shift, 0
          sleep 0.1
        end
        server.shutdown rescue nil
      }
    end

    def join
      @thread.join
    end
  end

  def setup
    @channel = Channel.new
    @handler = Net::SSH::Service::Forward::RemoteNetworkHandler.new(
      Log.new, 16, PORT, HOST )
  end

  def test_on_eof
    assert !@channel[:eof]
    @handler.on_eof( @channel )
    assert @channel[:eof]
  end

  def test_on_open
    server = ScriptedServer.new
    server.script << "1234567890123456"
    server.script << "abcdefghijklmnop"
    sleep 0.1
    @handler.on_open( @channel, nil, nil, nil, nil )
    server.join
    @handler.on_eof( @channel )
    sleep 0.1
    assert_equal [ "1234567890123456", "abcdefghijklmnop", :close ],
      @channel.events
  end

end
