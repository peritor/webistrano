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

require 'needle'
require 'needle/interceptor'
require 'needle/pipeline/interceptor'
require 'needle/service-point'
require 'test/unit'

class TC_ServicePoint < Test::Unit::TestCase

  class Model
    attr_reader :service_point
    attr_reader :name
    attr_reader :priority
    attr_accessor :succ

    def initialize(point,name,priority,opts={},&callback)
      @point = point
      @priority = priority || 0
    end
    def call( *args )
      succ.call( *args )
    end
    def <=>( item )
      priority <=> item.priority
    end
    def reset!
    end
  end

  class Container
    def initialize( descended=true )
      @descended = descended
    end

    def root
      self
    end

    def non_public_services_exist?
      true
    end

    def non_public_services_exist=( flag )
    end

    def []( name )
      case name
        when :service_models
          { :mock => [ :mock ] }
        when :pipeline_elements
          { :mock => Model, :interceptor => Needle::Pipeline::InterceptorElement }
      end
    end

    def fullname
      "container"
    end

    def descended_from?( c )
      @descended
    end
  end

  class Interceptor
    def initialize( point, opts )
    end
    def process( chain, context )
      chain.process_next( context )
    end
  end

  def setup
    @container = Container.new
  end

  def test_initialize
    point = nil

    assert_nothing_raised do
      point =
        Needle::ServicePoint.new( @container, "test", :model => :mock ) {
          Hash.new }
    end

    assert_equal "test", point.name
    assert_equal "container.test", point.fullname

    assert_nothing_raised do
      point =
        Needle::ServicePoint.new( @container, "test", :pipeline => [] ) {
          Hash.new }
    end
  end

  def test_instance_with_explicit_pipeline_class
    point =
      Needle::ServicePoint.new( @container, "test", :pipeline => [ Model ] ) {
        Hash.new }

    inst = point.instance(@container)
    assert_instance_of Hash, inst
  end

  def test_instance
    point =
      Needle::ServicePoint.new( @container, "test", :model => :mock ) {
        Hash.new }

    inst = point.instance(@container)
    assert_instance_of Hash, inst
  end

  def test_constructor_parms_single
    point =
      Needle::ServicePoint.new( @container, "test", :model => :mock ) do |c,p|
        assert_equal @container, c
        Hash.new
      end

    point.instance(@container)
  end

  def test_constructor_parms_multiple
    point =
      Needle::ServicePoint.new( @container, "test", :model => :mock ) do |c,p|
        assert_equal @container, c
        assert_equal point, p
        Hash.new
      end

    point.instance(@container)
  end

  def test_interceptor
    point =
      Needle::ServicePoint.new( @container, "test", :model => :mock ) {
        Hash.new }

    interceptor = Needle::Interceptor.new.with { Interceptor }
    point.interceptor interceptor

    inst = point.instance(@container)
    assert_instance_of Needle::InterceptorChainBuilder::InterceptedServiceProxy, inst
  end

  def test_interceptor_after_instance
    reg = Needle::Registry.new
    reg.define.foo { "hello" }

    events = []
    reg.intercept( :foo ).doing do |ch,ctx|
      events << "first"
      ch.process_next ctx
    end
    reg.intercept( :foo ).doing do |ch,ctx|
      events << "second"
      ch.process_next ctx
    end

    obj1 = reg.foo
    obj1.length
    assert_equal [ "first", "second" ], events

    events = []
    reg.intercept( :foo ).doing do |ch,ctx|
      events << "third"
      ch.process_next ctx
    end
        
    obj2 = reg.foo
    obj2.length
    assert_equal [ "first", "second", "third" ], events

    assert_not_same obj1, obj2
  end

end
