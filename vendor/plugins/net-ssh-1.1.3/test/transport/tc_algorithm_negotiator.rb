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

require 'net/ssh/transport/algorithm-negotiator'
require 'net/ssh/transport/constants'
require 'net/ssh/util/buffer'
require 'test/unit'

class TC_AlgorithmNegotiator < Test::Unit::TestCase
  include Net::SSH::Transport::Constants

  class MockLogger; def debug?; false; end; end

  class Buffers
    def writer
      Net::SSH::Util::WriterBuffer.new
    end
  end

  class ScriptedSession
    attr_reader :messages
    attr_reader :host, :port

    def initialize( *script )
      @script = script
      @messages = []
    end

    def wait_for_message
      @script.shift
    end

    def send_message( msg )
      @messages << msg.to_s
    end
  end

  ALGORITHMS = {
    :host_key => [ "A", "B" ],
    :kex => [ "C", "D" ],
    :encryption => [ "E", "F" ],
    :hmac => [ "G", "H" ],
    :compression => [ "I", "J" ],
    :languages => [ "K", "L" ],
  }

  def reader( text )
    Net::SSH::Util::ReaderBuffer.new( text )
  end

  def setup
    logger = MockLogger.new
    buffers = Buffers.new
    @negotiator = Net::SSH::Transport::AlgorithmNegotiator.new( logger, ALGORITHMS, buffers )
  end

  def test_no_kexinit
    session = ScriptedSession.new( [ -1, reader("") ] )
    assert_raise( Net::SSH::Exception ) do
      @negotiator.negotiate( session, {} )
    end
  end

  def test_simple_exchange
    session = ScriptedSession.new(
      [ KEXINIT,
        reader("1234567890123456" +
               "\0\0\0\3C,D" +
               "\0\0\0\3A,B" +
               "\0\0\0\3E,F\0\0\0\3E,F" +
               "\0\0\0\3G,H\0\0\0\3G,H" +
               "\0\0\0\3I,J\0\0\0\3I,J" +
               "\0\0\0\0\0\0\0\0\0\0\0\0\0") ]
    )

    result = @negotiator.negotiate( session, {} )

    assert_equal "C", result.kex
    assert_equal "A", result.host_key
    assert_equal "E", result.encryption_c2s
    assert_equal "E", result.encryption_s2c
    assert_equal "G", result.mac_c2s
    assert_equal "G", result.mac_s2c
    assert_equal "I", result.compression_c2s
    assert_equal "I", result.compression_s2c
    assert_equal "", result.language_c2s
    assert_equal "", result.language_s2c

    assert_equal "1234567890123456\0\0\0\3C,D\0\0\0\3A,B\0\0\0\3E,F\0\0\0\3E,F\0\0\0\3G,H\0\0\0\3G,H\0\0\0\3I,J\0\0\0\3I,J\0\0\0\0\0\0\0\0\0\0\0\0\0", result.server_packet
    assert_equal "\0\0\0\3C,D\0\0\0\3A,B\0\0\0\3E,F\0\0\0\3E,F\0\0\0\3G,H\0\0\0\3G,H\0\0\0\3I,J\0\0\0\3I,J\0\0\0\3K,L\0\0\0\3K,L\0\0\0\0\0", result.client_packet[17..-1]
  end

  def test_custom_exchange
    session = ScriptedSession.new(
      [ KEXINIT,
        reader("1234567890123456" +
               "\0\0\0\3C,D" +
               "\0\0\0\3A,B" +
               "\0\0\0\3E,F\0\0\0\3E,F" +
               "\0\0\0\3G,H\0\0\0\3G,H" +
               "\0\0\0\3I,J\0\0\0\3I,J" +
               "\0\0\0\0\0\0\0\0\0\0\0\0\0") ]
    )

    result = @negotiator.negotiate( session,
      :kex => "D",
      :host_key => [ "B", "A" ] )

    assert_equal "D", result.kex
    assert_equal "B", result.host_key
    assert_equal "E", result.encryption_c2s
    assert_equal "E", result.encryption_s2c
    assert_equal "G", result.mac_c2s
    assert_equal "G", result.mac_s2c
    assert_equal "I", result.compression_c2s
    assert_equal "I", result.compression_s2c
    assert_equal "", result.language_c2s
    assert_equal "", result.language_s2c
  end

  def test_bad_algorithm
    session = ScriptedSession.new(
      [ KEXINIT,
        reader("1234567890123456" +
               "\0\0\0\3C,D" +
               "\0\0\0\3A,B" +
               "\0\0\0\3E,F\0\0\0\3E,F" +
               "\0\0\0\3G,H\0\0\0\3G,H" +
               "\0\0\0\3I,J\0\0\0\3I,J" +
               "\0\0\0\0\0\0\0\0\0\0\0\0\0") ]
    )

    assert_raise( NotImplementedError ) do
      @negotiator.negotiate( session, :kex => "K" )
    end
  end

  def test_no_agree
    session = ScriptedSession.new(
      [ KEXINIT,
        reader("1234567890123456" +
               "\0\0\0\3C,D" +
               "\0\0\0\3M,N" +
               "\0\0\0\3E,F\0\0\0\3E,F" +
               "\0\0\0\3G,H\0\0\0\3G,H" +
               "\0\0\0\3I,J\0\0\0\3I,J" +
               "\0\0\0\0\0\0\0\0\0\0\0\0\0") ]
    )

    assert_raise( Net::SSH::Exception ) do
      @negotiator.negotiate( session, {} )
    end
  end

end
