#--
# =============================================================================
# Copyright (c) 2004, Jamis Buck (jamis@37signals.com)
# All rights reserved.
#
# This source file is distributed as part of the Needle dependency injection
# library for Ruby. This file (and the library as a whole) may be used only as
# allowed by either the BSD license, or the Ruby license (or, by association
# with the Ruby license, the GPL). See the "doc" subdirectory of the Needle
# distribution for the texts of these licenses.
# -----------------------------------------------------------------------------
# needle website : http://needle.rubyforge.org
# project website: http://rubyforge.org/projects/needle
# =============================================================================
#++

$:.unshift "../../lib"

require "needle/lifecycle/proxy"
require "test/unit"

class TC_LifecycleProxy < Test::Unit::TestCase

  def test_fail
    proxy = Needle::Lifecycle::Proxy.new( nil ) { Bogus.new }
    assert_raise( NameError ) do
      proxy.hello
    end
    assert_nothing_raised do
      proxy.hello
    end
  end

  def test_succeed
    instantiated = false
    proxy = Needle::Lifecycle::Proxy.new( nil ) { instantiated = true; Hash.new }
    assert !instantiated
    proxy[:test] = :value
    assert instantiated
    assert_equal :value, proxy[:test]
  end

  def test_container
    proxy = Needle::Lifecycle::Proxy.new( nil, :container ) do |c|
      assert_equal :container, c
      Hash.new
    end
    proxy[:test] = :value
  end

end
