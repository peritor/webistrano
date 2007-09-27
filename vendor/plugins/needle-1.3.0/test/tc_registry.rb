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

require 'needle/registry'
require 'test/unit'

class TC_Registry < Test::Unit::TestCase

  def setup
    @registry = Needle::Registry.new
  end

  def test_bootstrap
    assert_respond_to @registry, :service_models
    assert_instance_of Hash, @registry.service_models
    assert_equal 16, @registry.service_models.length
  end

  def test_define_no_options
    reg = Needle::Registry.define do |b|
      b.svc1 { Object.new }
    end

    assert_respond_to reg, :svc1
  end

  def test_define_with_options
    reg = Needle::Registry.define( :logs => { :device => STDOUT } ) do |b|
      b.svc1 { Object.new }
    end

    assert_respond_to reg, :svc1
    assert_equal STDOUT, reg.logs.device
  end

  def test_define_no_options!
    reg = Needle::Registry.define! do
      svc1 { Object.new }
    end

    assert_respond_to reg, :svc1
  end

  def test_define_with_options!
    reg = Needle::Registry.define!( :logs => { :device => STDOUT } ) do
      svc1 { Object.new }
    end

    assert_respond_to reg, :svc1
    assert_equal STDOUT, reg.logs.device
  end

  def test_new_no_options
    reg = Needle::Registry.new do |r|
      r.register( :svc ) { Object.new }
    end

    assert_respond_to reg, :svc
  end

  def test_new_with_options
    reg = Needle::Registry.new( :logs => { :device => STDOUT } ) do |r|
      r.register( :svc ) { Object.new }
    end

    assert_respond_to reg, :svc
    assert_equal STDOUT, reg.logs.device
  end

  def test_fullname
    assert_nil @registry.fullname
  end

  def test_nested_parent
    inner = Needle::Registry.new( :parent => @registry )
    assert_equal @registry, inner.parent
  end

  def test_nested_child_services_accessible_to_parent_services
    @registry.define do |b|
      b.override_me { "override_me" }
      b.use_override { |c, p| c.override_me.intern }
    end
    inner = Needle::Registry.define( :parent => @registry ) do |b|
      b.override_me { "the_child_override" }
    end
    assert_same(:the_child_override, inner[:use_override])
  end

  def test_explicit_name
    reg = Needle::Registry.new( :name => :test )
    assert_equal :test, reg.name
    assert_nil reg.fullname
  end

  def test_nested_fullname
    middle = Needle::Registry.new( :parent => @registry, :name => :middle )
    inner = Needle::Registry.new( :parent => middle, :name => :test )
    assert_equal "middle.test", inner.fullname
  end

  def test_bootstrap_once
    inner = Needle::Registry.new( :parent => @registry )
    assert inner.knows_key?( :pipeline_elements )
    assert !inner.has_key?( :pipeline_elements )
  end

  def test_parameterized_service
    reg = Needle::Registry.define do |b|
      b.require 'services', "A::B::C", :register_parameterized_services
    end

    assert_raise( ArgumentError ) do
      reg.baz1 "a", :b, 3
    end

    assert_equal "a:b:3", reg.baz2( "a", :b, 3 )
  end

end
