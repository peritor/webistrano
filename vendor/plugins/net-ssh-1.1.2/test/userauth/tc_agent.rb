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

require 'net/ssh/userauth/agent'
require 'net/ssh/util/buffer'
require 'test/unit'

class TC_Agent < Test::Unit::TestCase

  class MockReader < Net::SSH::Util::ReaderBuffer
    def read_bignum
      read_long
    end

    def read_key
      OpenStruct.new(
        :e    => read_bignum,
        :n    => read_bignum )
    end
  end

  class Buffers
    def writer
      Net::SSH::Util::WriterBuffer.new
    end

    def reader( text )
      MockReader.new( text )
    end
  end

  class SocketFactory
    attr_reader :socket_name
    attr_reader :events

    def initialize( data )
      @data = Net::SSH::Util::ReaderBuffer.new( data.to_s )
    end

    def open( name )
      @socket_name = name
      @events = []
      self
    end

    def close
      @events << :close
    end

    def send( data, flags )
      @events << data.to_s
    end

    def read( bytes )
      @data.read( bytes )
    end
  end

  class Keys
    def get( type )
      require 'ostruct'
      OpenStruct.new
    end
  end

  def setup
    @agent = Net::SSH::UserAuth::Agent.new
    @agent.socket_name = "test"
    @agent.version = 2
    @agent.buffers = Buffers.new
    @agent.keys = Keys.new
  end

  CONNECT_STR = "\0\0\0\1\2"

  def test_connect_bad_version
    @agent.socket_factory = SocketFactory.new( "\0\0\0\1\147" )
    assert_raise( NotImplementedError ) { @agent.connect! }
  end

  def test_connect_bad_response
    @agent.socket_factory = SocketFactory.new( "\0\0\0\1\0" )
    assert_raise( Net::SSH::UserAuth::AgentError ) { @agent.connect! }
  end

  def test_connect_success
    @agent.socket_factory = SocketFactory.new( CONNECT_STR )
    assert_nothing_raised { @agent.connect! }
  end

  IDENTITIES = { 1 => 1,
                 2 => 11 }

  [ 1, 2 ].each do |version|
    [ 5, 30, 102 ].each do |error_code|
      define_method( "test_identities_v#{version}_c#{error_code}" ) do
        @agent.version = version
        @agent.socket_factory = factory = SocketFactory.new( CONNECT_STR + "\0\0\0\1#{error_code.chr}" )
        @agent.connect!
        assert_raise( Net::SSH::UserAuth::AgentError ) { @agent.identities }
        assert_equal [ "\0\0\0\1#{IDENTITIES[version].chr}" ], factory.events[1..-1]
      end
    end

    define_method( "test_identities_v#{version}_bad_auth_code" ) do
      @agent.version = version
      @agent.socket_factory = factory = SocketFactory.new( CONNECT_STR + "\0\0\0\1\0" )
      @agent.connect!
      assert_raise( Net::SSH::UserAuth::AgentError ) { @agent.identities }
      assert_equal [ "\0\0\0\1#{IDENTITIES[version].chr}" ], factory.events[1..-1]
    end
  end

  def test_identities_v1_single
    @agent.version = 1
    @agent.socket_factory = SocketFactory.new( CONNECT_STR + "\0\0\0\32\2\0\0\0\1\1\2\3\4\1\1\1\1\2\2\2\2\0\0\0\5hello" )
    @agent.connect!
    identities = nil
    assert_nothing_raised { identities = @agent.identities }
    assert_equal [ OpenStruct.new( :e => 0x01010101, :n => 0x02020202 ) ], identities
    assert_equal "hello", identities.first.comment
  end

  def test_identities_v1_multiple
    @agent.version = 1
    @agent.socket_factory = SocketFactory.new( CONNECT_STR +
        "\0\0\0\57\2" +
        "\0\0\0\2" +
        "\1\2\3\4\1\1\1\1\2\2\2\2\0\0\0\5hello" +
        "\2\3\4\5\3\3\3\3\4\4\4\4\0\0\0\5howdy" )
    @agent.connect!
    identities = nil
    assert_nothing_raised { identities = @agent.identities }
    assert_equal [ OpenStruct.new( :e => 0x01010101, :n => 0x02020202 ),
      OpenStruct.new( :e => 0x03030303, :n => 0x04040404 ) ], identities
    assert_equal "hello", identities.first.comment
    assert_equal "howdy", identities.last.comment
  end

  def test_identities_v2_single
    @agent.version = 2
    @agent.socket_factory = SocketFactory.new( CONNECT_STR +
        "\0\0\0\32\14" +
        "\0\0\0\1" +
        "\0\0\0\10\1\1\1\1\2\2\2\2\0\0\0\5hello" )
    @agent.connect!
    identities = nil
    assert_nothing_raised { identities = @agent.identities }
    assert_equal [ OpenStruct.new( :e => 0x01010101, :n => 0x02020202 ) ], identities
    assert_equal "hello", identities.first.comment
  end

  def test_identities_v2_multiple
    @agent.version = 2
    @agent.socket_factory = SocketFactory.new( CONNECT_STR +
        "\0\0\0\57\14" +
        "\0\0\0\2" +
        "\0\0\0\10\1\1\1\1\2\2\2\2\0\0\0\5hello" +
        "\0\0\0\10\3\3\3\3\4\4\4\4\0\0\0\5howdy" )
    @agent.connect!
    identities = nil
    assert_nothing_raised { identities = @agent.identities }
    assert_equal [ OpenStruct.new( :e => 0x01010101, :n => 0x02020202 ),
      OpenStruct.new( :e => 0x03030303, :n => 0x04040404 ) ], identities
    assert_equal "hello", identities.first.comment
    assert_equal "howdy", identities.last.comment
  end

  def test_close
    @agent.socket_factory = factory = SocketFactory.new( CONNECT_STR )
    @agent.connect!
    @agent.close
    assert_equal :close, factory.events.last
  end

  [ 5, 30, 102 ].each do |error_code|
    define_method( "test_sign_error_#{error_code}" ) do
      @agent.socket_factory = SocketFactory.new( CONNECT_STR + "\0\0\0\1#{error_code.chr}" )
      @agent.connect!
      key = OpenStruct.new( :ssh_type => "ssh-rsa",
                            :e => OpenStruct.new( :to_ssh => "e" ),
                            :n => OpenStruct.new( :to_ssh => "n" ) )
      assert_raise( Net::SSH::UserAuth::AgentError ) { @agent.sign( key, "test" ) }
    end
  end

  def test_sign_bad_response
    @agent.socket_factory = SocketFactory.new( CONNECT_STR + "\0\0\0\1\0" )
    @agent.connect!
    key = OpenStruct.new( :ssh_type => "ssh-rsa",
                          :e => OpenStruct.new( :to_ssh => "e" ),
                          :n => OpenStruct.new( :to_ssh => "n" ) )
    assert_raise( Net::SSH::UserAuth::AgentError ) { @agent.sign( key, "test" ) }
  end

  def test_sign
    @agent.socket_factory = factory = SocketFactory.new( CONNECT_STR + "\0\0\0\12\16\0\0\0\5howdy" )
    @agent.connect!
    key = OpenStruct.new( :ssh_type => "ssh-rsa",
                          :e => OpenStruct.new( :to_ssh => "e" ),
                          :n => OpenStruct.new( :to_ssh => "n" ) )
    sig = nil
    assert_nothing_raised { sig = @agent.sign( key, "test" ) }
    assert_equal "howdy", sig
    assert_equal "\0\0\0\36\15\0\0\0\15\0\0\0\7ssh-rsaen\0\0\0\4test\0\0\0\0", factory.events.last
  end

end
