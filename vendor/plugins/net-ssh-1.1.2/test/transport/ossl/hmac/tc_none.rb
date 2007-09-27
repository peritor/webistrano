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

require 'net/ssh/transport/ossl/hmac/none'
require 'test/unit'

class TC_HMAC_None < Test::Unit::TestCase

  def setup
    @hmac = Net::SSH::Transport::OSSL::HMAC::None.new.new( "12345678901234567890" )
  end

  def test_key
    assert_equal "", @hmac.key
  end

  def test_key_length
    assert_equal 0, @hmac.key_length
  end

  def test_mac_length
    assert_equal 0, @hmac.mac_length
  end

  def test_digest_class
    assert_nil @hmac.digest_class
  end

  def test_digest
    expect = ""
    assert_equal expect,
      @hmac.digest( "To be, or not to be, that is the question" )
  end

end
