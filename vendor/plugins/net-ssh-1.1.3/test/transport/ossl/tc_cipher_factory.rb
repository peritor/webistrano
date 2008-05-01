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

require 'net/ssh/transport/ossl/cipher-factory'
require 'test/unit'

class TC_CipherFactory < Test::Unit::TestCase

  MockCipher = Object.new

  def setup
    map = { "bf" => "bf", "none" => "none" }
    @factory = Net::SSH::Transport::OSSL::CipherFactory.new( map )
    @factory.identity_cipher = MockCipher
  end

  def test_none
    cipher = @factory.get( "none" )
    assert_equal MockCipher, cipher
  end

  def test_bad_cipher
    assert_raise( Net::SSH::Transport::CipherNotFound ) do
      @factory.get "bogus"
    end
  end

  def test_cipher_short
    cipher = @factory.get( "bf", "1234", "1234", "IJKL", "MNOP",
                           OpenSSL::Digest::MD5, true )

    text = cipher.update( "12345678" )
    text << cipher.final

    assert_equal "\335\027\034\242?\243\0054", text
  end

  def test_cipher_exact
    cipher = @factory.get( "bf", "12345678", "1234567890123456", "IJKL",
                           "MNOP", OpenSSL::Digest::MD5, true )

    text = cipher.update( "12345678" )
    text << cipher.final

    assert_equal "\030&\317\021\363\200|E", text
  end

  def test_cipher_long
    cipher = @factory.get( "bf", "1234567890", "123456789012345678", "IJKL",
                           "MNOP", OpenSSL::Digest::MD5, true )

    text = cipher.update( "12345678" )
    text << cipher.final

    assert_equal "\030&\317\021\363\200|E", text
  end

  def test_cipher_lengths
    result = @factory.get_lengths( "bogus" )
    assert [0, 0], result

    result = @factory.get_lengths( "none" )
    assert [0, 0], result

    result = @factory.get_lengths( "bf" )
    assert [16, 8], result
  end

end
