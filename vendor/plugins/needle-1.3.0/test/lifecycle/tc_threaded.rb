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

require "needle/lifecycle/threaded"
require "test/unit"

class TC_Lifecycle_Threaded < Test::Unit::TestCase

  def setup
    mock = Struct.new( :fullname ).new( "test" )
    @counter = 0
    @element = Needle::Lifecycle::Threaded.new( mock )
    @element.succ = Proc.new { @counter += 1 }
  end

  def test_single_thread
    @element.call(1,2)
    @element.call(1,2)
    @element.call(1,2)
    assert_equal 1, @counter
  end

  def test_multi_thread
    threads = []
    threads << Thread.new { @element.call(1,2) }
    threads << Thread.new { @element.call(1,2) }
    threads << Thread.new { @element.call(1,2) }
    threads.each { |t| t.join }
    assert_equal 3, @counter
  end

  def test_extra_args_disallowed
    assert_raise( ArgumentError ) do
      @element.call(1,2,3)
    end
  end

end
