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
require 'net/ssh/transport/ossl/key-factory'
require 'test/unit'

class TC_OSSLKeyFactory < Test::Unit::TestCase

  class Prompter
    def initialize( passwd )
      @passwd = passwd
    end

    def password( prompt )
      if @passwd.is_a? Array
        @passwd.shift
      else
        @passwd
      end
    end
  end

  class Buffers
    def reader( text )
      Net::SSH::Transport::OSSL::ReaderBuffer.new( text )
    end
  end

  def fixture( name )
    "#{File.dirname __FILE__}/fixtures/#{name}"
  end

  def setup
    algos = { "test" => String }
    @factory = Net::SSH::Transport::OSSL::KeyFactory.new( algos )
    @factory.buffers = Buffers.new
  end

  def test_get_found
    key = nil
    assert_nothing_raised { key = @factory.get( "test" ) }
    assert_equal "", key
  end

  def test_get_not_found
    assert_raise( Net::SSH::Transport::KeyTypeNotFound ) do
      @factory.get( "bogus" )
    end
  end

  def test_load_private_key_not_found
    assert_raise( Errno::ENOENT ) do
      @factory.load_private_key "bogus"
    end
  end

  def test_load_private_key_not_supported
    assert_raise( OpenSSL::PKey::PKeyError ) do
      @factory.load_private_key fixture( "not-supported" )
    end
  end

  def test_load_private_key_not_private_key
    assert_raise( OpenSSL::PKey::PKeyError ) do
      @factory.load_private_key fixture( "not-a-private-key" )
    end
  end

  def test_load_private_key_dsa_unencrypted_fail
    assert_raise( OpenSSL::PKey::DSAError ) do
      @factory.load_private_key fixture( "dsa-unencrypted-bad" )
    end
  end

  def test_load_private_key_dsa_unencrypted_success
    result = nil
    assert_nothing_raised do
      result = @factory.load_private_key fixture( "dsa-unencrypted" )
    end
    assert_instance_of OpenSSL::PKey::DSA, result
  end

  def test_load_private_key_rsa_unencrypted_fail
    assert_raise( OpenSSL::PKey::RSAError ) do
      @factory.load_private_key fixture( "rsa-unencrypted-bad" )
    end
  end

  def test_load_private_key_rsa_unencrypted_success
    result = nil
    assert_nothing_raised do
      result = @factory.load_private_key fixture( "rsa-unencrypted" )
    end
    assert_instance_of OpenSSL::PKey::RSA, result
  end

  def test_load_private_key_dsa_encrypted_fail_bad
    @factory.prompter = Prompter.new( "key-test" )
    assert_raise( OpenSSL::PKey::DSAError ) do
      @factory.load_private_key fixture( "dsa-encrypted-bad" )
    end
  end

  def test_load_private_key_dsa_encrypted_fail_wrong_password
    @factory.prompter = Prompter.new( "key-test-bad" )
    assert_raise( OpenSSL::PKey::DSAError ) do
      @factory.load_private_key fixture( "dsa-encrypted" )
    end
  end

  def test_load_private_key_dsa_encrypted_success
    @factory.prompter = Prompter.new( "key-test" )
    result = nil
    assert_nothing_raised do
      result = @factory.load_private_key fixture( "dsa-encrypted" )
    end
    assert_instance_of OpenSSL::PKey::DSA, result
  end

  def test_load_private_key_rsa_encrypted_fail_bad
    @factory.prompter = Prompter.new( "key-test" )
    assert_raise( OpenSSL::PKey::RSAError ) do
      @factory.load_private_key fixture( "rsa-encrypted-bad" )
    end
  end

  def test_load_private_key_rsa_encrypted_fail_wrong_password
    @factory.prompter = Prompter.new( "key-test-bad" )
    assert_raise( OpenSSL::PKey::RSAError ) do
      @factory.load_private_key fixture( "rsa-encrypted" )
    end
  end

  def test_load_private_key_rsa_encrypted_success
    @factory.prompter = Prompter.new( "key-test" )
    result = nil
    assert_nothing_raised do
      result = @factory.load_private_key fixture( "rsa-encrypted" )
    end
    assert_instance_of OpenSSL::PKey::RSA, result
  end

  def test_load_public_key_not_found
    assert_raise( Errno::ENOENT ) do
      @factory.load_public_key "bogus"
    end
  end

  def test_load_public_key_success_rsa
    result = nil
    assert_nothing_raised do
      result = @factory.load_public_key fixture( "rsa-unencrypted.pub" )
    end
    assert_instance_of OpenSSL::PKey::RSA, result
  end

  def test_load_public_key_success_dsa
    result = nil
    assert_nothing_raised do
      result = @factory.load_public_key fixture( "dsa-unencrypted.pub" )
    end
    assert_instance_of OpenSSL::PKey::DSA, result
  end

  def test_load_private_key_encrypted_bad_passwd_thrice
    passwords = [ "one", "two", "three", "four" ]
    @factory.prompter = Prompter.new( passwords )
    assert_raise( OpenSSL::PKey::DSAError ) do
      @factory.load_private_key fixture( "dsa-encrypted" )
    end
    assert_equal [ "four" ], passwords
  end

  def test_load_private_key_encrypted_good_passwd_eventually
    passwords = [ "one", "two", "key-test" ]
    @factory.prompter = Prompter.new( passwords )
    assert_nothing_raised do
      @factory.load_private_key fixture( "dsa-encrypted" )
    end
    assert passwords.empty?
  end

end
