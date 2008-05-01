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

require 'net/ssh/transport/identity-cipher'
require 'test/unit'

class TC_IdentityCipher < Test::Unit::TestCase

  def setup
    @cipher = Net::SSH::Transport::IdentityCipher.new
  end

  def test_block_size
    assert_equal 8, @cipher.block_size
  end

  def test_encrypt
    @cipher.encrypt
    text = @cipher.update( "value1" )
    text << @cipher.update( "value2" )
    text << @cipher.final
    assert_equal text, "value1value2"
  end

  def test_decrypt
    @cipher.decrypt
    text = @cipher.update( "value1" )
    text << @cipher.update( "value2" )
    text << @cipher.final
    assert_equal text, "value1value2"
  end

  def test_name
    assert_equal "identity", @cipher.name
  end

end
