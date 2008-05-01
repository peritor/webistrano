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

require 'net/ssh/transport/ossl/hmac-factory'
require 'test/unit'

class TC_HMACFactory < Test::Unit::TestCase

  class MockHMAC
    attr_reader :key_length
    attr_reader :key

    def initialize
      @key_length = 8
    end

    def new( key )
      @key = key
      self
    end
  end

  def setup
    map = [ { "test" => MockHMAC.new } ]
    @factory = Net::SSH::Transport::OSSL::HMACFactory.new( map )
  end

  def test_get_not_found
    assert_raise( Net::SSH::Transport::HMACAlgorithmNotFound ) do
      @factory.get( "bogus" )
    end
  end

  def test_get_found
    hmac = nil
    assert_nothing_raised do
      hmac = @factory.get( "test", "12345678" )
    end
    assert_equal 8, hmac.key_length
    assert_equal "12345678", hmac.key
  end

  def test_get_key_length_not_found
    assert_raise( Net::SSH::Transport::HMACAlgorithmNotFound ) do
      @factory.get_key_length( "bogus" )
    end
  end

  def test_get_key_length_found
    length = nil
    assert_nothing_raised do
      length = @factory.get_key_length( "test" )
    end
    assert_equal 8, length
  end

end
