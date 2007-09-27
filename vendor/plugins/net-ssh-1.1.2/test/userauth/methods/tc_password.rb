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

require 'net/ssh/userauth/methods/password'
require 'net/ssh/util/buffer'
require 'test/unit'
require 'ostruct'

class TC_Methods_Password < Test::Unit::TestCase

  class Buffers
    def writer
      Net::SSH::Util::WriterBuffer.new
    end
  end

  class Messenger
    attr_reader :data
    attr_reader :messages

    def initialize
      @data = []
      @messages = []
    end

    def send_message( msg )
      @messages << msg.to_s
    end

    def wait_for_message
      @data.shift
    end
  end

  def setup
    buffers = Buffers.new
    @messenger = Messenger.new
    @password = Net::SSH::UserAuth::Methods::Password.new( buffers )
    @password.messenger = @messenger
  end

  def test_authenticate_no_password
    assert !@password.authenticate( "test", "test_user" )
    assert @messenger.messages.empty?
  end

  def test_authenticate_success
    @messenger.data << OpenStruct.new( :message_type => 52 )
    assert @password.authenticate( "test", "test_user", :password => "passwd" )
    assert_equal 1, @messenger.messages.length
    assert_equal "#{50.chr}\0\0\0\11test_user\0\0\0\4test\0\0\0\10password\0\0\0\0\6passwd",
      @messenger.messages.last
  end

  def test_authenticate_failure
    @messenger.data << OpenStruct.new( :message_type => 51 )
    assert !@password.authenticate( "test", "test_user", :password => "passwd" )
    assert !@messenger.messages.empty?
  end

  def test_authenticate_passwd_changereq
    @messenger.data << OpenStruct.new( :message_type => 60 )
    assert !@password.authenticate( "test", "test_user", :password => "passwd" )
    assert !@messenger.messages.empty?
  end

  def test_authenticate_bad_reply
    @messenger.data << OpenStruct.new( :message_type => 0 )
    assert_raise( Net::SSH::Exception ) do
      @password.authenticate( "test", "test_user", :password=>"passwd" )
    end
  end

end
