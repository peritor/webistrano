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

require 'net/ssh/userauth/driver'
require 'net/ssh/util/buffer'
require 'test/unit'

class TC_UserAuth_Driver < Test::Unit::TestCase

  class Log
    def debug?
      false
    end
  end

  class Buffers
    def writer
      Net::SSH::Util::WriterBuffer.new
    end
  end

  class KeyManager
    attr_reader :events

    def initialize
      @events = []
    end

    def clear!
      @events << :clear!
    end

    def clear_host!
      @events << :clear_host!
    end

    def finish
      @events << :finish
    end

    def add( file )
      @events << { :name => :add, :file => file }
    end
    alias :<< :add

    def add_host_key( file )
      @events << { :name => :add_host_key, :file => file }
    end
  end

  class Session
    attr_reader :script
    attr_reader :messages

    def initialize
      @script = []
      @messages = []
    end

    def send_message( message )
      @messages << message
    end

    def wait_for_message
      type, data = @script.shift
      [ type, Net::SSH::Util::ReaderBuffer.new( data ) ]
    end
  end

  class AuthMethod
    attr_reader :next_service
    attr_reader :username
    attr_reader :data

    def initialize( good )
      @good = good
    end

    def authenticate( next_service, username, data={} )
      @next_service = next_service
      @username = username
      @data = data
      @good
    end
  end

  def setup
    @methods = { :test_fail => AuthMethod.new( false ),
                :test_succeed => AuthMethod.new( true ) }
    order = [ "test-fail", "test-succeed" ]
    @driver = Net::SSH::UserAuth::Driver.new( Log.new,
      Buffers.new, @methods, order )
    @driver.session = @session = Session.new
    @driver.key_manager = @manager = KeyManager.new
  end

  def test_set_key_files
    @driver.set_key_files [ :one, :two ]
    assert_equal [ :clear!,
                   { :name => :add, :file => :one },
                   { :name => :add, :file => :two } ], @manager.events
  end

  def test_set_host_key_files
    @driver.set_host_key_files [ :one, :two ]
    assert_equal [ :clear_host!,
                   { :name => :add_host_key, :file => :one },
                   { :name => :add_host_key, :file => :two } ], @manager.events
  end

  def test_order
    assert_equal [ "test-fail", "test-succeed" ], @driver.order
    original = [ "one", "two", "three" ]
    @driver.set_auth_method_order( original )
    @driver.order << "four"
    assert_equal [ "one", "two", "three" ], original
    assert_equal [ "one", "two", "three", "four" ], @driver.order
    @driver.set_auth_method_order(*original)
    assert_equal [ "one", "two", "three" ], @driver.order
  end

  def test_on_banner
    msg = lang = nil
    @driver.on_banner { |m,l| msg, lang = m, l }
    @session.script << [ 53, "\0\0\0\15hello, world!\0\0\0\2en" ]
    @session.script << [ 51, "\0\0\0\15howdy, earth!\0" ]
    result = @driver.wait_for_message

    assert_equal "hello, world!", msg
    assert_equal "en", lang
    assert_equal 51, result.message_type
  end

  def test_send_message
    @driver.send_message "konnichi wa"
    assert_equal [ "konnichi wa" ], @session.messages
  end

  def test_authenticate_bad_reply
    @session.script << [ 0, "\0\0\0\0" ]
    assert_raise( Net::SSH::Exception ) do
      @driver.authenticate( "service", "test_user", "passwd" )
    end
  end

  def test_authenticate_unexpected_reply
    @session.script << [ 60, "\0\0\0\0" ]
    assert_raise( Net::SSH::Exception ) do
      @driver.authenticate( "service", "test_user", "passwd" )
    end
  end

  def test_authenticate
    @session.script << [ 6, "\0\0\0\14ssh-userauth" ]
    assert @driver.authenticate( "service", "test_user", "passwd" )

    @methods.each_value do |method|
      assert_equal "service", method.next_service
      assert_equal "test_user", method.username
      assert_equal( { :password => "passwd", :key_manager => @manager }, method.data )
    end

    assert_equal :finish, @manager.events.last
  end

  def test_authenticate_not_implemented
    @session.script << [ 6, "\0\0\0\14ssh-userauth" ]
    @driver.set_auth_method_order "bogus"
    assert_raise( NotImplementedError ) do
      @driver.authenticate( "service", "test_user", "passwd" )
    end
    assert_equal :finish, @manager.events.last
  end

end
