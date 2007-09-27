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

require 'needle/pipeline/collection'
require 'test/unit'

class TC_Pipeline_Collection < Test::Unit::TestCase

  class MockElement
    attr_reader :service_point
    attr_reader :name
    attr_reader :priority
    attr_accessor :succ

    attr_reader :events

    def initialize( point, name, priority, options )
      @service_point = point
      @name, @priority = name, priority
      @events = []
    end

    def call( *args )
      args.first << "|Mock"
      succ.call( *args )
      args.first << "|Done"
    end

    def <=>( element )
      priority <=> element.priority
    end

    def reset!
      @events << :reset!
    end
  end

  def setup
    elements = Struct.new( :fullname, :pipeline_elements ).new(
      "test", { :mock => MockElement, :mock2 => MockElement } )
    point = Struct.new( :container, :fullname ).new( elements, "test" )
    @collection = Needle::Pipeline::Collection.new( point )
  end

  def test_add_anonymous_block
    @collection.add do |me,*args|
      args.first << "|A"
      result = me.succ.call( *args )
      args.first << "|B"
      result
    end

    chain = @collection.chain_to( proc { |a| a << "|tail" } )
    b = ""
    chain.call( b )
    assert_equal b, "|A|tail|B"
  end

  def test_add_named_block
    @collection.add( "block" ) do |chain,*args|
      args.first << "|A"
      result = chain.call( *args )
      args.first << "|B"
      result
    end

    assert_not_nil @collection.get( :block )
  end

  def test_add_named_element
    @collection.add :mock

    chain = @collection.chain_to( proc { |a| a << "|tail" } )
    b = ""
    chain.call( b )
    assert_equal b, "|Mock|tail|Done"
  end

  def test_add_prioritize
    @collection.add :mock, 50
    @collection.add 25 do |me,*args|
      args.first << "|proc"
      r = me.succ.call( *args )
      args.first << "|end"
      r
    end

    chain = @collection.chain_to( proc { |a| a << "|tail" } )
    b = ""
    chain.call( b )
    assert_equal b, "|Mock|proc|tail|end|Done"
  end

  def test_add_prioritize_reverse
    @collection.add :mock, 25
    @collection.add 50 do |me,*args|
      args.first << "|proc"
      r = me.succ.call( *args )
      args.first << "|end"
      r
    end

    chain = @collection.chain_to( proc { |a| a << "|tail" } )
    b = ""
    chain.call( b )
    assert_equal b, "|proc|Mock|tail|Done|end"
  end

  def test_reset_one!
    @collection.add :mock, 25
    @collection.add :mock2, 25
    @collection.reset! :mock2
    assert_equal [ :reset! ], @collection.get( :mock2 ).events
    assert_equal [], @collection.get( :mock ).events
  end

  def test_reset!
    @collection.add :mock, 25
    @collection.add :mock2, 25
    @collection.reset!
    assert_equal [ :reset! ], @collection.get( :mock2 ).events
    assert_equal [ :reset! ], @collection.get( :mock ).events
  end

end
