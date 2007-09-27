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

require 'net/ssh/errors'
require 'net/ssh/null-host-key-verifier'
require 'net/ssh/transport/kex/dh'
require 'net/ssh/util/buffer'
require 'test/unit'
require 'ostruct'

class TC_KEX_DH < Test::Unit::TestCase

  class MockDH < Struct.new( :valid, :p, :g, :priv_key, :pub_key )
    def valid?
      valid
    end
    
    def compute_key( num )
      num
    end

    def generate_key!
      self.pub_key = MockBN.new( priv_key )
    end
  end

  class MockServerKey
    attr_reader :result

    def initialize( result )
      @result = result
    end

    def ssh_do_verify( sig, hash )
      @result
    end

    def ssh_type
      "ssh-test"
    end
  end

  class MockKeys
    def get( type )
      raise "not DH" unless type == "dh"
      return MockDH.new( true )
    end
  end

  class MockBN
    attr_reader :value

    def initialize( value )
      @value = value
    end

    def to_i( *args )
      @value.to_i( *args )
    end

    def to_ssh
      "[#{@value}]"
    end
  end

  class MockBNs
    def new( value, base )
      return value if value.is_a?( Numeric )
      MockBN.new( value.to_i( base ) )
    end

    def rand( bits )
      bits
    end
  end

  class MockDigest
    def self.digest( text )
      text
    end
  end

  class MockReaderBuffer < Net::SSH::Util::ReaderBuffer
    def read_key
      MockServerKey.new( read )
    end

    def read_bignum
      MockBN.new( read_string )
    end
  end

  class MockBuffers
    def writer( text="" ); Net::SSH::Util::WriterBuffer.new( text ); end
    def reader( text ); MockReaderBuffer.new( text ); end
  end

  class MockDigests
    def get( type )
      raise "not SHA1" unless type == "sha1"
      return MockDigest
    end
  end

  class MockSession
    attr_reader :sent_buffer

    def initialize( *script )
      @script = script
    end

    def send_message( buffer )
      @sent_buffer = buffer
    end

    def wait_for_message
      [ @script.shift, @script.shift ]
    end

    def peer
      {}
    end

    def algorithms
      OpenStruct.new( :host_key => "ssh-test" )
    end
  end

  def setup
    @kex = Net::SSH::Transport::Kex::DiffieHellmanGroup1SHA1.new(
      MockBNs.new, MockDigests.new )
    @kex.keys = MockKeys.new
    @kex.buffers = MockBuffers.new
    @kex.host_key_verifier = Net::SSH::NullHostKeyVerifier.new

    @init  = Net::SSH::Transport::Kex::DiffieHellmanGroup1SHA1::KEXDH_INIT
    @reply = Net::SSH::Transport::Kex::DiffieHellmanGroup1SHA1::KEXDH_REPLY
    @session_id = "\0\0\0\1A\0\0\0\1B\0\0\0\1C\0\0\0\1D\0\0\0\1E[10][20][30]"

    @exchange_keys_script = [
      31,
      MockReaderBuffer.new( "\0\0\0\10key blob\0\0\0\0041001\0\0\0\27\0\0\0\10ssh-test\0\0\0\11signature" ),
      21,
      nil
    ]

    @exchange_keys_session_id = "\0\0\0\1A\0\0\0\1B\0\0\0\1C\0\0\0\1D\0\0\0\10key blob[80][1001][9]"
  end

  def test_generate_key
    dh = nil
    assert_nothing_raised do
      dh = @kex.generate_key( nil, { :need_bytes=>10 } )
    end

    expected_p = 
0xFFFFFFFF_FFFFFFFF_C90FDAA2_2168C234_C4C6628B_80DC1CD1_29024E08_8A67CC74_020BBEA6_3B139B22_514A0879_8E3404DD_EF9519B3_CD3A431B_302B0A6D_F25F1437_4FE1356D_6D51C245_E485B576_625E7EC6_F44C42E9_A637ED6B_0BFF5CB6_F406B7ED_EE386BFB_5A899FA5_AE9F2411_7C4B1FE6_49286651_ECE65381_FFFFFFFF_FFFFFFFF

    assert_equal expected_p, dh.p.to_i
    assert_equal 2, dh.g
    assert_equal 80, dh.priv_key
  end

  def test_verify_server_key
    key = OpenStruct.new( :ssh_type => "test" )
    session = OpenStruct.new( :algorithms => OpenStruct.new( :host_key => "test" ) )
    assert_nothing_raised { @kex.verify_server_key( key, session ) }

    session = OpenStruct.new( :algorithms => OpenStruct.new( :host_key => "bogus" ) )
    assert_raise( Net::SSH::Exception ) {
      @kex.verify_server_key( key, session ) }
  end

  def test_send_kexinit
    dh = MockDH.new
    dh.pub_key = MockBN.new( 80 )
    session = MockSession.new( @reply, :worked )

    result = nil
    assert_nothing_raised do
      result = @kex.send_kexinit( dh, session )
    end

    assert_equal :worked, result
    assert_equal "#{@init.chr}[80]", session.sent_buffer.to_s

    session = MockSession.new( @reply+1, :worked )

    assert_raise( Net::SSH::Exception ) do
      @kex.send_kexinit( dh, session )
    end
  end

  def test_parse_kex_reply
    dh = MockDH.new

    buffer = Net::SSH::Util::WriterBuffer.new
    buffer.write_string "key blob"
    buffer.write_string "1001"

    sigbuf = Net::SSH::Util::WriterBuffer.new
    sigbuf.write_string "ssh-test"
    sigbuf.write_string "signature"
    buffer.write_string sigbuf

    buffer = MockReaderBuffer.new( buffer.content )

    result = nil
    assert_nothing_raised do
      result = @kex.parse_kex_reply( dh, buffer, MockSession.new )
    end

    assert_equal "key blob", result[:key_blob]
    assert_equal "key blob", result[:server_key].result
    assert_equal "1001", result[:server_dh_pubkey].value
    assert_equal 9, result[:shared_secret].to_i
    assert_equal "signature", result[:server_sig]

    buffer = Net::SSH::Util::WriterBuffer.new
    buffer.write_string "key blob"
    buffer.write_string "1001"

    sigbuf = Net::SSH::Util::WriterBuffer.new
    sigbuf.write_string "ssh-bogus"
    sigbuf.write_string "signature"
    buffer.write_string sigbuf

    buffer = MockReaderBuffer.new( buffer.content )
    assert_raise( Net::SSH::Exception ) do
      @kex.parse_kex_reply( dh, buffer, MockSession.new )
    end
  end

  def test_verify_signature
    dh = MockDH.new
    dh.p = MockBN.new( 2 )
    dh.g = MockBN.new( 6 )
    dh.pub_key = MockBN.new( 10 )

    data = { :client_version_string => "A",
             :server_version_string => "B",
             :client_algorithm_packet => "C",
             :need_bits => 0,
             :server_algorithm_packet => "D" }
    result = { :key_blob => "E",
               :server_dh_pubkey => MockBN.new( 20 ),
               :shared_secret => MockBN.new( 30 ),
               :server_key => MockServerKey.new( true ) }

    session_id = nil
    assert_nothing_raised do
      session_id = @kex.verify_signature( dh, data, result )
    end

    assert_equal @session_id, session_id

    result[:server_key] = MockServerKey.new( false )
    assert_raise( Net::SSH::Exception ) do
      @kex.verify_signature( dh, data, result )
    end
  end

  def test_confirm_newkeys
    session = MockSession.new( 21, :worked )

    assert_nothing_raised do
      @kex.confirm_newkeys( session )
    end

    assert_equal 21.chr, session.sent_buffer.to_s

    session = MockSession.new( 22, :worked )
    assert_raise( Net::SSH::Exception ) do
      @kex.confirm_newkeys( session )
    end
  end

  def test_exchange_keys
    session = MockSession.new( *@exchange_keys_script )
    data = { :need_bytes => 10,
             :client_version_string => "A",
             :server_version_string => "B",
             :client_algorithm_packet => "C",
             :server_algorithm_packet => "D" }

    result = nil
    assert_nothing_raised do
      result = @kex.exchange_keys( session, data )
    end

    assert_equal MockDigest, result.hashing_algorithm
    assert_equal @exchange_keys_session_id, result.session_id
    assert_equal "key blob", result.server_key.result
    assert_equal 9, result.shared_secret.to_i
  end

end
