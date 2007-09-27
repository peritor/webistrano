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

require 'net/ssh/userauth/methods/hostbased'
require 'net/ssh/util/buffer'
require 'test/unit'
require 'ostruct'

class TC_Methods_HostBased < Test::Unit::TestCase

  class Buffers
    def writer
      Net::SSH::Util::WriterBuffer.new
    end
  end

  class Key < OpenStruct
    def initialize( e, n )
      super( :ssh_type => "ssh-rsa",
             :e => OpenStruct.new( :to_ssh => [ e ].pack("N") ),
             :n => OpenStruct.new( :to_ssh => [ n ].pack("N") ) )
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

  class KeyManager
    attr_reader :host_identities
    attr_reader :state
    attr_reader :sigdata

    def initialize( *identities )
      @host_identities = identities.flatten
      @state = :open
    end

    def sign( identity, data )
      @sigdata = [ identity, data.to_s ]
      "<signature>"
    end

    def finish
      @state = :finished
    end
  end

  def setup
    ENV["USER"] = "test_client_user"
    buffers = Buffers.new
    @messenger = Messenger.new
    @method = Net::SSH::UserAuth::Methods::HostBased.new( buffers )
    @method.messenger = @messenger
    @method.session_id = "test"
    @method.hostname = "test.host"
  end

  def test_authenticate_no_key_manager
    assert !@method.authenticate( "test", "test_user" )
    assert @messenger.messages.empty?
  end

  def test_authenticate_no_identities
    manager = KeyManager.new
    assert !@method.authenticate( "test", "test_user", :key_manager => manager )
    assert_equal :finished, manager.state
  end

  def test_authenticate_success
    manager = KeyManager.new( Key.new( 0x01010101, 0x02020202 ) )
    @messenger.data.concat [ OpenStruct.new( :message_type => 52 ) ]
    assert @method.authenticate( "test", "test_user", :key_manager => manager )
    assert_equal :finished, manager.state
    assert_equal 1, @messenger.messages.length

    sig = "#{50.chr}\0\0\0\11test_user\0\0\0\4test\0\0\0\11hostbased\0\0\0\7ssh-rsa" +
          "\0\0\0\23\0\0\0\7ssh-rsa\1\1\1\1\2\2\2\2" +
          "\0\0\0\12test.host.\0\0\0\20test_client_user"
    packet1 = sig + "\0\0\0\13<signature>"
    assert_equal packet1, @messenger.messages[0]

    sigdata = manager.sigdata
    assert_equal "\0\0\0\4test" + sig, sigdata[1]
  end

  def test_authenticate_fail
    manager = KeyManager.new( Key.new( 0x01010101, 0x02020202 ),
                              Key.new( 0x03030303, 0x04040404 ) )
    @messenger.data.concat [ OpenStruct.new( :message_type => 51 ),
                             OpenStruct.new( :message_type => 51 ) ]
    assert !@method.authenticate( "test", "test_user", :key_manager => manager )
    assert_equal :finished, manager.state
    assert_equal 2, @messenger.messages.length
  end

  def test_authenticate_acceptible_identities_error
    manager = KeyManager.new( Key.new( 0x01010101, 0x02020202 ) )
    @messenger.data.concat [ OpenStruct.new( :message_type => 60 ),
                             OpenStruct.new( :message_type => 0 ) ]
    assert_raise( Net::SSH::Exception ) do
      @method.authenticate( "test", "test_user", :key_manager => manager )
    end
    assert_equal 1, @messenger.messages.length
  end

end
