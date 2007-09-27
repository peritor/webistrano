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
require 'net/ssh/proxy/http'
require 'socket'

class TC_Proxy_HTTP < Test::Unit::TestCase

  HOST = "test.host"
  PORT = 22117

  class ScriptableHTTPServer
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
      loop do
        @events << client.readline 
        break if @events.last == "\n"
      end
      client.puts @script.shift
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
    ENV['HTTP_PROXY_USER'] = nil
    ENV['HTTP_PROXY_PASSWORD'] = nil
    ENV['CONNECT_USER'] = nil
    ENV['CONNECT_PASSWORD'] = nil

    @server = ScriptableHTTPServer.new
    @options = Hash.new
    @proxy = Net::SSH::Proxy::HTTP.new( HOST, PORT, @options )
  end

  def teardown
    @server.shutdown
  end

  def test_no_auth_ok
    @server.script << "HTTP/1.0 200 OK\n\n"
    @server.run

    @proxy.open( "foo.com", 1234 )
    @server.wait

    assert_equal [ "CONNECT foo.com:1234 HTTP/1.0\n", "\n" ], @server.events
  end

  def test_connect_error
    @server.script << "HTTP/1.0 500 Error\n\n"
    @server.run

    assert_raise( Net::SSH::Proxy::ConnectError ) do
      @proxy.open( "foo.com", 1234 )
    end

    @server.wait

    assert_equal [ "CONNECT foo.com:1234 HTTP/1.0\n", "\n" ], @server.events
  end

  def test_unauthorized_error_no_user
    @server.script << "HTTP/1.0 407 Error\n\n"
    @server.run

    assert_raise( Net::SSH::Proxy::UnauthorizedError ) do
      @proxy.open( "foo.com", 1234 )
    end

    @server.wait

    assert_equal [ "CONNECT foo.com:1234 HTTP/1.0\n", "\n" ], @server.events
  end

  def test_invalid_auth_scheme
    @options[:user] = 'test'

    @server.script << "HTTP/1.0 407 Error\nProxy-Authenticate: Foo 1 2 3\n\n"
    @server.run

    assert_raise( NotImplementedError ) do
      @proxy.open( "foo.com", 1234 )
    end

    @server.wait

    assert_equal [ "CONNECT foo.com:1234 HTTP/1.0\n", "\n" ], @server.events
  end

  def test_connect_error_bad_auth
    @options[:user] = 'test'
    @options[:password] = 'password'

    @server.script << "HTTP/1.0 407 Error\nProxy-Authenticate: Basic\n\n"
    @server.script << "HTTP/1.0 500 Error\n\n"
    @server.run

    assert_raise( Net::SSH::Proxy::ConnectError ) do
      @proxy.open( "foo.com", 1234 )
    end

    @server.wait

    assert_equal [ "CONNECT foo.com:1234 HTTP/1.0\n", "\n",
                   "CONNECT foo.com:1234 HTTP/1.0\n",
                   "Proxy-Authorization: Basic dGVzdDpwYXNzd29yZA==\n", "\n" ],
                  @server.events
  end

  def test_connect_auth_success
    @options[:user] = 'test'
    @options[:password] = 'password'

    @server.script << "HTTP/1.0 407 Error\nProxy-Authenticate: Basic\n\n"
    @server.script << "HTTP/1.0 200 OK\n\n"
    @server.run

    assert_nothing_raised do
      @proxy.open( "foo.com", 1234 )
    end

    @server.wait

    assert_equal [ "CONNECT foo.com:1234 HTTP/1.0\n", "\n",
                   "CONNECT foo.com:1234 HTTP/1.0\n",
                   "Proxy-Authorization: Basic dGVzdDpwYXNzd29yZA==\n", "\n" ],
                  @server.events
  end

  def test_connect_auth_success_with_HTTP_PROXY_vars
    ENV['HTTP_PROXY_USER'] = 'test'
    ENV['HTTP_PROXY_PASSWORD'] = 'password'

    @server.script << "HTTP/1.0 407 Error\nProxy-Authenticate: Basic\n\n"
    @server.script << "HTTP/1.0 200 OK\n\n"
    @server.run

    assert_nothing_raised do
      @proxy.open( "foo.com", 1234 )
    end

    @server.wait

    assert_equal [ "CONNECT foo.com:1234 HTTP/1.0\n", "\n",
                   "CONNECT foo.com:1234 HTTP/1.0\n",
                   "Proxy-Authorization: Basic dGVzdDpwYXNzd29yZA==\n", "\n" ],
                  @server.events
  end

  def test_connect_auth_success_with_CONNECT_vars
    ENV['CONNECT_USER'] = 'test'
    ENV['CONNECT_PASSWORD'] = 'password'

    @server.script << "HTTP/1.0 407 Error\nProxy-Authenticate: Basic\n\n"
    @server.script << "HTTP/1.0 200 OK\n\n"
    @server.run

    assert_nothing_raised do
      @proxy.open( "foo.com", 1234 )
    end

    @server.wait

    assert_equal [ "CONNECT foo.com:1234 HTTP/1.0\n", "\n",
                   "CONNECT foo.com:1234 HTTP/1.0\n",
                   "Proxy-Authorization: Basic dGVzdDpwYXNzd29yZA==\n", "\n" ],
                  @server.events
  end

end
