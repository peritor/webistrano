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

require 'net/ssh/transport/ossl/buffer'
require 'test/unit'

class TC_OSSLBuffer < Test::Unit::TestCase

  def setup
    @buffer = Net::SSH::Transport::OSSL::ReaderBuffer.new( "" )
  end

  def test_read_bignum
    @buffer.append "\x00\x00\x00\x01\x01" +
                   "\x00\x00\x00\x04\x12\x34\x56\x78" +
                   "\x00\x00\x00\x07\x00\xAB\xCD\xEF\x12\x34\x56"
    a = @buffer.read_bignum
    b = @buffer.read_bignum
    c = @buffer.read_bignum
    d = @buffer.read_bignum
    assert_equal 0x01, a
    assert_equal 0x12345678, b
    assert_equal 0xABCDEF123456, c
    assert_nil d
  end

  def test_read_key
    @buffer.append "\x00\x00\x00\x07ssh-dss" +
                   "\x00\x00\x00\x01\x01" +
                   "\x00\x00\x00\x01\x02" +
                   "\x00\x00\x00\x01\x03" +
                   "\x00\x00\x00\x01\x04" +
                   "\x00\x00\x00\x07ssh-rsa" +
                   "\x00\x00\x00\x01\x01" +
                   "\x00\x00\x00\x01\x02"

    k1 = @buffer.read_key
    k2 = @buffer.read_key
    k3 = @buffer.read_key

    assert_instance_of OpenSSL::PKey::DSA, k1
    assert_instance_of OpenSSL::PKey::RSA, k2
    assert_equal 0x01, k1.p
    assert_equal 0x02, k1.q
    assert_equal 0x03, k1.g
    assert_equal 0x04, k1.pub_key
    assert_equal 0x01, k2.e
    assert_equal 0x02, k2.n
    assert_nil k3
  end

  def test_read_keyblob
    blob1 = "\x00\x00\x00\x01\x01" +
            "\x00\x00\x00\x01\x02" +
            "\x00\x00\x00\x01\x03" +
            "\x00\x00\x00\x01\x04" +

    blob2 = "\x00\x00\x00\x01\x01" +
            "\x00\x00\x00\x01\x02"

    @buffer.append blob1
    @buffer.append blob2

    k1 = @buffer.read_keyblob( "ssh-dss" )
    k2 = @buffer.read_keyblob( "ssh-rsa" )

    assert_raises( NotImplementedError ) do
      k3 = @buffer.read_keyblob( "bogus" )
    end

    assert_instance_of OpenSSL::PKey::DSA, k1
    assert_instance_of OpenSSL::PKey::RSA, k2
    assert_equal 0x01, k1.p
    assert_equal 0x02, k1.q
    assert_equal 0x03, k1.g
    assert_equal 0x04, k1.pub_key
    assert_equal 0x01, k2.e
    assert_equal 0x02, k2.n
  end


end
