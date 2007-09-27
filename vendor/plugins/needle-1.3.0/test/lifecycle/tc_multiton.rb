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

require "needle/lifecycle/multiton"
require "test/unit"

class TC_Lifecycle_Multiton < Test::Unit::TestCase

  def test_multiplicity
    element = Needle::Lifecycle::Multiton.new( nil )
    element.succ = Proc.new { |c,p,x| "value: #{x}" }
    p1 = element.call( nil, nil, :v )
    p2 = element.call( nil, nil, :v )
    assert_same p1, p2
    p3 = element.call( nil, nil, :x )
    assert_not_same p1, p3
  end

  def test_reset!
    element = Needle::Lifecycle::Multiton.new( nil )
    element.succ = Proc.new { |c,p,x| "value: #{x}" }
    p1 = element.call( nil, nil, :v )
    element.reset!
    p2 = element.call( nil, nil, :v )
    assert_not_same p1, p2
  end

end
