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
require 'net/ssh/util/buffer'
require 'net/ssh/util/openssl'

class BufferTester

  def initialize( test_case, buffer )
    @buffer = buffer
    @test_case = test_case
  end

  def run_tests
    methods.each do |meth|
      next unless meth =~ /^test_/
      @buffer.clear!
      send meth
    end
  end

end

class WriteBufferTester < BufferTester

  def test_write
    @buffer.write "hello", "\x1\x2\x3\x4"
    @test_case.assert_equal( "hello\x1\x2\x3\x4", @buffer.content )
  end

  def test_write_int64
    @buffer.write_int64 0x1234567898765432
    expect = "\x12\x34\x56\x78\x98\x76\x54\x32"
    @test_case.assert_equal( expect, @buffer.content )
    @buffer.write_int64 1, 2
    expect << "\x00\x00\x00\x00\x00\x00\x00\x01"
    expect << "\x00\x00\x00\x00\x00\x00\x00\x02"
    @test_case.assert_equal( expect, @buffer.content )
  end

  def test_write_long
    @buffer.write_long 0x12ABCDEF, 7
    @test_case.assert_equal( "\x12\xAB\xCD\xEF\x00\x00\x00\x07", @buffer.content )
  end

  def test_write_short
    @buffer.write_short 0x12AB, 7
    @test_case.assert_equal( "\x12\xAB\x00\x07", @buffer.content )
  end

  def test_write_byte
    @buffer.write_byte 0x12, 0xAB, 7
    @test_case.assert_equal( "\x12\xAB\x07", @buffer.content )
  end

  def test_write_string
    @buffer.write_string "hello", "\x01\x02\x03\x04\x05\x06"
    @test_case.assert_equal( "\x00\x00\x00\x05hello\x00\x00\x00\x06\x01\x02\x03\x04\x05\x06", @buffer.content )
  end

  def test_write_bool
    @buffer.write_bool true, false
    @test_case.assert_equal( "\x01\x00", @buffer.content )
  end

  def test_write_bignum
    bn = OpenSSL::BN.new( "1" )
    @buffer.write_bignum OpenSSL::BN.new( "1" ),
      OpenSSL::BN.new( "12345678", 16 ),
      OpenSSL::BN.new( "ABCDEF123456", 16 )
    expect = "\x00\x00\x00\x01\x01" +
             "\x00\x00\x00\x04\x12\x34\x56\x78" +
             "\x00\x00\x00\x07\x00\xAB\xCD\xEF\x12\x34\x56"
    @test_case.assert_equal( expect, @buffer.content )
  end

  def test_write_key
    key = OpenSSL::PKey::DSA.new
    key.p, key.q, key.g, key.pub_key = 1, 2, 3, 4
    @buffer.write_key key
    key = OpenSSL::PKey::RSA.new
    key.e, key.n = 1, 2
    @buffer.write_key key

    expect = "\x00\x00\x00\x07ssh-dss" +
             "\x00\x00\x00\x01\x01" +
             "\x00\x00\x00\x01\x02" +
             "\x00\x00\x00\x01\x03" +
             "\x00\x00\x00\x01\x04" +
             "\x00\x00\x00\x07ssh-rsa" +
             "\x00\x00\x00\x01\x01" +
             "\x00\x00\x00\x01\x02"
    @test_case.assert_equal( expect, @buffer.content )
  end

end

class ReadBufferTester < BufferTester

  def test_append
    @buffer.append "some text"
    @test_case.assert_equal( "some text", @buffer.content )
    @buffer.append "some more text"
    @test_case.assert_equal( "some textsome more text", @buffer.content )
  end

  def test_remainder_as_buffer
    @buffer.append "\x01\x02\x03\x04\x05\x06\x07"
    @buffer.read_byte
    b = @buffer.remainder_as_buffer
    @test_case.assert_equal( "\x02\x03\x04\x05\x06\x07", b.content )
  end

  def test_read
    @buffer.append "\x01\x02\x03\x04\x05\x06\x07"
    @test_case.assert_equal( "\x01", @buffer.read(1) )
    @test_case.assert_equal( "\x02\x03", @buffer.read(2) )
    @test_case.assert_equal( "\x04\x05\x06\x07", @buffer.read )
  end

  def test_read_int64
    @buffer.append "\x12\x34\x56\x78\x98\x76\x54\x32"
    i = @buffer.read_int64
    @test_case.assert_equal( 0x1234567898765432, i )
  end

  def test_read_long
    @buffer.append "\x12\x34\x56\x78\x00\x00\x00\x05"
    i = @buffer.read_long
    j = @buffer.read_long
    k = @buffer.read_long
    @test_case.assert_equal i, 0x12345678
    @test_case.assert_equal j, 5
    @test_case.assert_nil k
  end

  def test_read_short
    @buffer.append "\x12\x34\x00\x05"
    i = @buffer.read_short
    j = @buffer.read_short
    @test_case.assert_equal i, 0x1234
    @test_case.assert_equal j, 5
  end

  def test_read_string
    @buffer.append "\x00\x00\x00\x05hello, world"
    s = @buffer.read_string
    @test_case.assert_equal s, "hello"
  end

  def test_read_bool
    @buffer.append "\x01\x00"
    a = @buffer.read_bool
    b = @buffer.read_bool
    @test_case.assert a
    @test_case.assert !b
  end

end


class TC_WriterBuffer < Test::Unit::TestCase

  def test_buffer
    tester = WriteBufferTester.new( self, Net::SSH::Util::WriterBuffer.new )
    tester.run_tests
  end

end

class TC_ReaderBuffer < Test::Unit::TestCase

  def test_buffer
    tester = ReadBufferTester.new( self, Net::SSH::Util::ReaderBuffer.new( "" ) )
    tester.run_tests
  end

end

class TC_Buffer < Test::Unit::TestCase

  def test_write_buffer
    tester = WriteBufferTester.new( self, Net::SSH::Util::Buffer.new )
    tester.run_tests
  end

  def test_read_buffer
    tester = ReadBufferTester.new( self, Net::SSH::Util::Buffer.new )
    tester.run_tests
  end

end

if $0 == __FILE__
puts <<EOF
==========================================================================
NOTE: this file will run the tests for the BUFFER routines. If you want to
run a comprehensive test involving all of the suites written for Net::SSH,
run the 'tests.rb' file instead.
==========================================================================
EOF
end
