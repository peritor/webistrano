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
require 'net/ssh/proxy/socks4'
require 'socket'

class TC_Proxy_SOCKS4 < Test::Unit::TestCase

  HOST = "test.host"
  PORT = 22117

  class ScriptableSOCKS4Server
    attr_reader :script
    attr_reader :events

    def initialize
      @script = []
      @events = []
    end

    def run
      @socket = TCPServer.new( HOST, PORT )
      @thread = Thread.new { run_server until @script.empty? }
    end

    def run_server
      client = @socket.accept
      packet = client.read(8)
      c = nil
      packet << c while ( c = client.read(1) ) != "\0"
      packet << "\0"
      @events << packet
      client.send @script.shift, 0
    rescue Exception => e
      puts "#{e.class}: #{e.message}"
      puts e.backtrace.join("\n")
    end

    def wait
      @thread.join
    end

    def shutdown
      @socket.close
    end
  end

  def setup
    ENV['SOCKS_USER'] = nil
    ENV['CONNECT_USER'] = nil

    @server = ScriptableSOCKS4Server.new
    @options = Hash.new
    @proxy = Net::SSH::Proxy::SOCKS4.new( HOST, PORT, @options )
  end

  def teardown
    @server.shutdown
  end

  def test_no_auth_ok
    @server.script << "\4\132\0\0\0\0\0\0\0\0"
    @server.run

    assert_nothing_raised do
      @proxy.open( "test.host", 1234 )
    end

    @server.wait

    assert_equal [ "\4\1\4\xD2\x7F\0\0\1\0" ], @server.events
  end

  def test_no_auth_fail
    @server.script << "\4\133\0\0\0\0\0\0\0\0"
    @server.run

    assert_raise( Net::SSH::Proxy::ConnectError ) do
      @proxy.open( "test.host", 1234 )
    end

    @server.wait

    assert_equal [ "\4\1\4\xD2\x7F\0\0\1\0" ], @server.events
  end

  def test_auth_options
    @options[:user] = "test"

    @server.script << "\4\132\0\0\0\0\0\0\0\0"
    @server.run

    assert_nothing_raised do
      @proxy.open( "test.host", 1234 )
    end

    @server.wait

    assert_equal [ "\4\1\4\xD2\x7F\0\0\1test\0" ], @server.events
  end

  def test_auth_SOCKS_var
    ENV["SOCKS_USER"] = "test"

    @server.script << "\4\132\0\0\0\0\0\0\0\0"
    @server.run

    assert_nothing_raised do
      @proxy.open( "test.host", 1234 )
    end

    @server.wait

    assert_equal [ "\4\1\4\xD2\x7F\0\0\1test\0" ], @server.events
  end

  def test_auth_CONNECT_var
    ENV["CONNECT_USER"] = "test"

    @server.script << "\4\132\0\0\0\0\0\0\0\0"
    @server.run

    assert_nothing_raised do
      @proxy.open( "test.host", 1234 )
    end

    @server.wait

    assert_equal [ "\4\1\4\xD2\x7F\0\0\1test\0" ], @server.events
  end

end
