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

require "needle/lifecycle/deferred"
require "test/unit"

class TC_Lifecycle_Deferred < Test::Unit::TestCase

  def test_instantiability
    instantiated = false
    element = Needle::Lifecycle::Deferred.new( nil )
    element.succ = Proc.new { instantiated = true; Hash.new }

    assert !instantiated
    proto = element.call
    assert !instantiated
    proto[:test] = :value
    assert instantiated
    assert_equal :value, proto[:test]
  end

end
