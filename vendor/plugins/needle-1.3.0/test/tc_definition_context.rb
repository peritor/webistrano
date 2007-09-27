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

$:.unshift "../lib"

require 'needle/definition-context'
require 'needle/registry'
require 'test/unit'

class TC_DefinitionContext < Test::Unit::TestCase

  class MockContainer
    attr_reader :events
    attr_reader :defaults
    def initialize; @events = []; @defaults = Hash.new; end
    def method_missing(s,*a,&b)
      @events << { :name => s, :args => a, :block => b }
    end
    def use!( opts )
      orig = @defaults
      @defaults = opts

      if block_given?
        yield self
        @defaults = orig
      end

      orig
    end
  end

  def setup
    @container = MockContainer.new
    @ctx = Needle::DefinitionContext.new( @container )
  end

  def test_register
    assert_nothing_raised do
      @ctx.hello { "world" }
    end
    assert_equal :register, @container.events[0][:name]
    assert_equal [ :hello ], @container.events[0][:args]
    assert_not_nil @container.events[0][:block]
  end

  def test_reference_missing_parameterized
    @ctx.hello( :arg )
    assert_equal( { :name => :get, :args => [ :hello, :arg ], :block => nil },
      @container.events[0] )
  end

  def test_reference_missing_empty
    assert_nothing_raised do
      @ctx.hello 
    end
    assert_equal :get, @container.events[0][:name]
    assert_equal [ :hello ], @container.events[0][:args]
    assert_nil @container.events[0][:block]
  end

  def test_intercept
    assert_nothing_raised do
      @ctx.intercept( :foo )
    end
    assert_equal :intercept, @container.events[0][:name]
    assert_equal [ :foo ], @container.events[0][:args]
    assert_nil @container.events[0][:block]
  end

  def test_this_container
    assert_equal @container, @ctx.this_container
  end

  def test_use_bang_without_block
    @ctx.use! :foo => :bar
    assert_equal :bar, @container.defaults[:foo]
    @ctx.use! :blah => :baz
    assert_equal :baz, @container.defaults[:blah]
    assert_nil @container.defaults[:foo]
  end

  def test_use_bang_with_block
    @ctx.use! :foo => :bar do |r|
      assert_equal r.object_id, @ctx.object_id
      assert_equal :bar, @container.defaults[:foo]
      @ctx.use! :blah => :baz do
        assert_nil @container.defaults[:foo]
        assert_equal :baz, @container.defaults[:blah]
      end
      assert_nil @container.defaults[:blah]
      assert_equal :bar, @container.defaults[:foo]
    end
    assert_nil @container.defaults[:foo]
  end

  def test_use_without_block
    @ctx.use :foo => :bar
    assert_equal :bar, @container.defaults[:foo]
    @ctx.use :blah => :baz
    assert_equal :baz, @container.defaults[:blah]
    assert_equal :bar, @container.defaults[:foo]
  end

  def test_use_with_block
    @ctx.use :foo => :bar do |r|
      assert_equal r.object_id, @ctx.object_id
      assert_equal :bar, @container.defaults[:foo]
      @ctx.use :blah => :baz do
        assert_equal :bar, @container.defaults[:foo]
        assert_equal :baz, @container.defaults[:blah]
      end
      assert_nil @container.defaults[:blah]
      assert_equal :bar, @container.defaults[:foo]
    end
    assert_nil @container.defaults[:foo]
  end

end
