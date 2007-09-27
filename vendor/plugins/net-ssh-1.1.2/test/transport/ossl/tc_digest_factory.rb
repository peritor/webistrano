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

require 'net/ssh/transport/ossl/digest-factory'
require 'test/unit'

class TC_OSSLDigestFactory < Test::Unit::TestCase

  def setup
    map = { "test" => "hello" }
    @factory = Net::SSH::Transport::OSSL::DigestFactory.new( map )
  end

  def test_get_not_found
    assert_raise( Net::SSH::Transport::DigestTypeNotFound ) do
      @factory.get( "bogus" )
    end
  end

  def test_get_found
    assert_equal "hello", @factory.get( "test" )
  end

end
