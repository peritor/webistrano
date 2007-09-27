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

require 'net/ssh/transport/packet-stream'
require 'net/ssh/util/buffer'
require 'test/unit'

module PacketStream_Mock
  class Cipher
    def block_size
      8
    end

    def update( text )
      "!" + text
    end

    def final
      "!"
    end
  end

  class NullCipher
    def block_size; 8; end
    def update( text ); text; end
    def final; ""; end
  end

  class HMAC
    def mac_length
      8
    end

    def digest( text )
      text[0,mac_length]
    end
  end

  class Compressor
    def initialize( b="<", e=">" )
      @b, @e = b, e
    end

    def compress( text )
      "#{@b}#{text}#{@e}"
    end
  end

  class Decompressor
    def decompress( text )
      text
    end
  end

  class CipherFactory
    def initialize( klass )
      @klass = klass
    end

    def get( name )
      raise ArgumentError, "expected \"none\", got #{name.inspect}" unless name=="none"
      @klass.new
    end
  end

  class HMACFactory
    def get( name )
      raise ArgumentError, "expected \"none\", got #{name.inspect}" unless name=="none"
      HMAC.new
    end
  end

  class BufferFactory
    def reader( text )
      Net::SSH::Util::ReaderBuffer.new( text )
    end
  end

  class Socket
    attr_reader :send_buffer

    def initialize( source="" )
      @send_buffer = ""
      @source = source
    end

    def recv( bytes )
      result, @source = @source[0,bytes], @source[bytes..-1]
      result
    end

    def send( text, arg )
      @send_buffer << text
    end
  end

  Compressors = { "none" => Compressor.new }
  Decompressors = { "none" => Decompressor.new }
end

class TC_OutgoingPacketStream < Test::Unit::TestCase

  def setup
    @stream = Net::SSH::Transport::OutgoingPacketStream.new( 
      PacketStream_Mock::CipherFactory.new( PacketStream_Mock::Cipher ),
      PacketStream_Mock::HMACFactory.new,
      PacketStream_Mock::Compressors )
    @socket = PacketStream_Mock::Socket.new
    @stream.socket = @socket
  end

  def test_send_empty
    assert_equal 0, @stream.sequence_number
    @stream.send( "" )
    assert_equal 1, @stream.sequence_number
    assert_match( %r{^!\0\0\0\24\21<>.................!\0\0\0\0\0\0\0\24$}m, @socket.send_buffer )
  end

  def test_send_nonstring
    assert_equal 0, @stream.sequence_number
    @stream.send( 15 )
    assert_equal 1, @stream.sequence_number
    assert_match( %r{^!\0\0\0\24\17<15>...............!\0\0\0\0\0\0\0\24$}m, @socket.send_buffer )
  end

  def test_send_long_string
    assert_equal 0, @stream.sequence_number
    @stream.send( "12345678901234567" )
    assert_equal 1, @stream.sequence_number
    assert_match( %r{^!\0\0\0\34\10<12345678901234567>........!\0\0\0\0\0\0\0\034$}m, @socket.send_buffer )
  end

end

class TC_IncomingPacketStream < Test::Unit::TestCase

  class MockLog
    def debug?
      false
    end
  end

  def setup
    @stream = Net::SSH::Transport::IncomingPacketStream.new( 
      PacketStream_Mock::CipherFactory.new( PacketStream_Mock::NullCipher ),
      PacketStream_Mock::HMACFactory.new,
      PacketStream_Mock::Decompressors )
    @stream.buffers = PacketStream_Mock::BufferFactory.new
    @stream.log = MockLog.new
  end

  def test_get_empty
    @stream.socket = PacketStream_Mock::Socket.new( "\0\0\0\21\0201234567890123456\0\0\0\0\0\0\0\21" )
    assert_equal 0, @stream.sequence_number
    buffer = @stream.get
    assert_equal 1, @stream.sequence_number
    assert_equal 0, buffer.length
  end

  def test_get_long
    @stream.socket = PacketStream_Mock::Socket.new( "\0\0\0\32\020ABCDEFGHI1234567890123456\0\0\0\0\0\0\0\32" )
    assert_equal 0, @stream.sequence_number
    buffer = @stream.get
    assert_equal 1, @stream.sequence_number
    assert_equal 9, buffer.length
    assert_equal "ABCDEFGHI", buffer.to_s
  end
end
