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
require 'net/ssh/proxy/socks5'
require 'socket'

class TC_Proxy_SOCKS5 < Test::Unit::TestCase

  HOST = "test.host"
  PORT = 22117

  class ScriptableSOCKS5Server
    attr_reader :script
    attr_reader :events

    def initialize
      @script = []
      @events = []
    end

    def run
      @socket = TCPServer.new( HOST, PORT )
      @thread = Thread.new { run_server }
    end

    def run_server
      client = @socket.accept

      data = client.read(2)
      count = data[1]
      data << client.read(count)
      @events << data
      client.send @script.shift, 0
      return if @script.empty?

      if count > 1
        data = client.read(2)
        data << client.read(data[data.length-1]+1)
        data << client.read(data[data.length-1])
        @events << data
        client.send @script.shift, 0
        return if @script.empty?
      end

      data = client.read(4)
      t = data[3]
      if t == 1
        data << client.read(4)
      elsif t == 3
        data << client.read(1)
        length = data[4]
        data << client.read(length)
      end
      data << client.read(2)
      @events << data
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
    ENV['SOCKS_PASSWORD'] = nil
    ENV['CONNECT_USER'] = nil
    ENV['CONNECT_PASSWORD'] = nil

    @server = ScriptableSOCKS5Server.new
    @options = Hash.new
    @proxy = Net::SSH::Proxy::SOCKS5.new( HOST, PORT, @options )
  end

  def teardown
    @server.shutdown
  end

  def test_bad_version
    @server.script << "\4\0"
    @server.run

    assert_raise( Net::SSH::Proxy::Error ) do
      @proxy.open( "test.host", 1234 )
    end

    @server.wait

    assert_equal [ "\5\1\0" ], @server.events
  end

  def test_no_supported_methods
    @server.script << "\5\xff"
    @server.run

    assert_raise( Net::SSH::Proxy::Error ) do
      @proxy.open( "test.host", 1234 )
    end

    @server.wait

    assert_equal [ "\5\1\0" ], @server.events
  end

  def test_no_auth_fail
    @server.script << "\5\0"
    @server.script << "\5\1\0\0\4\0\0\0\0\0\0"
    @server.run

    assert_raise( Net::SSH::Proxy::ConnectError ) do
      @proxy.open( "test.host", 1234 )
    end

    @server.wait

    assert_equal [ "\5\1\0", "\5\1\0\3\11test.host\4\322" ], @server.events
  end

  def test_no_auth_succeed_atyp_ipv4
    @server.script << "\5\0"
    @server.script << "\5\0\0\0\4\0\0\0\0\0\0"
    @server.run

    assert_nothing_raised do
      @proxy.open( "1.2.3.4", 1234 )
    end

    @server.wait

    assert_equal [ "\5\1\0", "\5\1\0\1\1\2\3\4\4\322" ], @server.events
  end

  def test_no_auth_succeed_atyp_domain
    @server.script << "\5\0"
    @server.script << "\5\0\0\0\4\0\0\0\0\0\0"
    @server.run

    assert_nothing_raised do
      @proxy.open( "test.host", 1234 )
    end

    @server.wait

    assert_equal [ "\5\1\0", "\5\1\0\3\11test.host\4\322" ], @server.events
  end

  def test_authorize_fail
    @options[:user], @options[:password] = "foo", "bar"

    @server.script << "\5\2"
    @server.script << "\5\1"
    @server.run

    assert_raise( Net::SSH::Proxy::UnauthorizedError ) do
      @proxy.open( "test.host", 1234 )
    end

    @server.wait

    assert_equal [ "\5\2\0\2", "\1\3foo\3bar" ], @server.events
  end

  [ 
    [:options,
      lambda { |o| o[:user], o[:password] = "foo", "bar" } ],
    [:socks,
      lambda { ENV['SOCKS_USER'], ENV['SOCKS_PASSWORD'] = "foo", "bar" } ],
    [:connect,
      lambda { ENV['CONNECT_USER'], ENV['CONNECT_PASSWORD'] = "foo", "bar" } ]
  ].each do |name, cb|
    define_method "test_authorize_via_#{name}".to_sym do
      cb.call( @options )
      
      @server.script << "\5\2"
      @server.script << "\5\0"
      @server.script << "\5\0\0\0\4\0\0\0\0\0\0"
      @server.run

      assert_nothing_raised do
        @proxy.open( "test.host", 1234 )
      end

      @server.wait

      assert_equal [ "\5\2\0\2", "\1\3foo\3bar",
        "\5\1\0\3\11test.host\4\322" ], @server.events
    end
  end

end
