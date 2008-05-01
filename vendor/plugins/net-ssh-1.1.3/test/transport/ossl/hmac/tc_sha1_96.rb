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

$:.unshift "#{File.dirname(__FILE__)}/../../../../lib"

require 'net/ssh/transport/ossl/hmac/sha1-96'
require 'test/unit'

class TC_HMAC_SHA1_96 < Test::Unit::TestCase

  def setup
    @hmac = Net::SSH::Transport::OSSL::HMAC::SHA1_96.new.new( "1234567890123456789012345" )
  end

  def test_key
    assert_equal "12345678901234567890", @hmac.key
  end

  def test_key_length
    assert_equal 20, @hmac.key_length
  end

  def test_mac_length
    assert_equal 12, @hmac.mac_length
  end

  def test_digest_class
    assert_equal OpenSSL::Digest::SHA1, @hmac.digest_class
  end

  def test_digest
    expect = "\203\266\253\336\242\311zE\360~\325j"
    assert_equal expect,
      @hmac.digest( "To be, or not to be, that is the question" )
  end

end
