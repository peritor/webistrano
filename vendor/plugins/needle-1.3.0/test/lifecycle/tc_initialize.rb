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

require "needle/lifecycle/initialize"
require "test/unit"

class TC_Lifecycle_Initialize < Test::Unit::TestCase

  class MockNoInit
  end

  class MockInit
    attr_reader :value

    def initialize_service
      @value = :initialize
    end

    def custom_init
      @value = :custom
    end
  end

  def test_no_initialize
    element = Needle::Lifecycle::Initialize.new( nil )
    element.succ = Proc.new { MockNoInit.new }
    result = nil
    assert_nothing_raised { result = element.call }
    assert_instance_of MockNoInit, result
  end

  def test_initialize
    element = Needle::Lifecycle::Initialize.new( nil )
    element.succ = Proc.new { MockInit.new }
    result = element.call
    assert_equal :initialize, result.value
  end

  def test_custom_initialize
    element = Needle::Lifecycle::Initialize.new( nil, nil, nil,
      :init_method => :custom_init )
    element.succ = Proc.new { MockInit.new }
    result = element.call
    assert_equal :custom, result.value
  end

end
