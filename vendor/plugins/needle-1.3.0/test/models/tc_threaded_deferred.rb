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

require "needle"
require "test/unit"
require File.join( File.dirname( __FILE__ ), "model_test" )

class TC_Model_Threaded_Deferred < Test::Unit::TestCase
  include ModelTest

  use :threaded_deferred

  assert_threaded
  assert_deferred
  assert_no_init

end
