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

require 'needle/pipeline/element'
require 'test/unit'

class TC_Pipeline_Element < Test::Unit::TestCase

  def test_default_priority
    assert_equal 0, Needle::Pipeline::Element.default_priority
    element = Needle::Pipeline::Element.new nil
    assert_equal Needle::Pipeline::Element.default_priority, element.priority
  end

  def test_default_name
    element = Needle::Pipeline::Element.new nil
    assert_nil element.name
  end

  def test_name
    element = Needle::Pipeline::Element.new nil, :test
    assert_equal :test, element.name
  end

  def test_priority
    element = Needle::Pipeline::Element.new nil, :test, 50
    assert_equal 50, element.priority
  end

  def test_index_operator
    element = Needle::Pipeline::Element.new nil
    assert_raise( NotImplementedError ) { element[:arg] }
  end

  def test_call
    element = Needle::Pipeline::Element.new nil
    assert_raise( NotImplementedError ) { element.call( :arg ) }
  end

  def test_ordering
    element1 = Needle::Pipeline::Element.new( nil, :test1, 25 )
    element2 = Needle::Pipeline::Element.new( nil, :test2, 75 )

    assert_equal( -1, element1 <=> element2 )
    assert_equal(  1, element2 <=> element1 )
  end

  def test_comparable
    element1 = Needle::Pipeline::Element.new( nil, :test1, 25 )
    element2 = Needle::Pipeline::Element.new( nil, :test2, 75 )

    assert element1 < element2
    assert element2 > element1
    assert element1 != element2
  end

end
