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

require 'test/unit'

require 'needle/container'
require 'needle/definition-context'
require 'needle/interceptor'
require 'needle/lifecycle/deferred'
require 'needle/lifecycle/initialize'
require 'needle/lifecycle/singleton'
require 'needle/lifecycle/threaded'
require 'needle/log-factory'
require 'needle/logging-interceptor'
require 'needle/pipeline/interceptor'

class TC_Container < Test::Unit::TestCase

  class CustomContainer < Needle::Container
  end

  class CustomBuilder < Needle::DefinitionContext
  end

  class CustomInterceptor < Needle::Interceptor
  end

  def new_container( *args )
    container = Needle::Container.new( *args )

    container.register( :pipeline_elements, :pipeline=>[] ) { Hash.new }
    container.pipeline( :pipeline_elements ).add( :singleton,
      Needle::Lifecycle::Singleton )

    container[:pipeline_elements].update(
      :singleton   => Needle::Lifecycle::Singleton,
      :initialize  => Needle::Lifecycle::Initialize,
      :deferred    => Needle::Lifecycle::Deferred,
      :interceptor => Needle::Pipeline::InterceptorElement,
      :threaded    => Needle::Lifecycle::Threaded
    )

    container.register( :service_models, :pipeline=>[:singleton] ) { Hash.new }
    container[:service_models].update(
      :prototype                     => [],
      :prototype_initialize          => [ :initialize ],
      :prototype_deferred            => [ :deferred ],
      :prototype_deferred_initialize => [ :deferred, :initialize ],
      :singleton                     => [ :singleton ],
      :singleton_initialize          => [ :singleton, :initialize ],
      :singleton_deferred            => [ :singleton, :deferred ],
      :singleton_deferred_initialize => [ :singleton, :deferred, :initialize ],
      :threaded                      => [ :threaded ],
      :threaded_initialize           => [ :threaded, :initialize ],
      :threaded_deferred             => [ :threaded, :deferred ],
      :threaded_deferred_initialize  => [ :threaded, :deferred, :initialize ]
    )

    container.register( :definition_context_factory ) { Needle::DefinitionContext }
    container.register( :namespace_impl_factory ) { Needle::Container }
    container.register( :interceptor_impl_factory ) { Needle::Interceptor }

    container.register( :logs ) { LogFactory.new( opts[:logs] || {} ) }
    container.register( :logging_interceptor ) { Needle::LoggingInterceptor }

    container
  end

  def test_default
    container = new_container
    assert_nil container.parent
    assert_nil container.name
    assert_equal container, container.root
    assert_equal "", container.fullname
  end

  def test_named
    container = new_container( nil, "name" )
    assert_nil container.parent
    assert_equal "name", container.name
    assert_equal container, container.root
    assert_equal "name", container.fullname
  end

  def test_nested
    outer = new_container
    inner = new_container( outer )
    assert_same outer, inner.parent
    assert_equal outer, inner.root
  end

  def test_root
    outer = new_container
    middle = new_container( outer )
    inner = new_container( middle )
    assert_same middle, inner.parent
    assert_equal outer, inner.root
  end

  def test_nested_named
    outer = new_container( nil, "outer" )
    inner = new_container( outer, "inner" )
    assert_equal "inner", inner.name
    assert_equal "outer.inner", inner.fullname
  end

  def test_service_not_found
    container = new_container
    assert_raise( Needle::ServiceNotFound ) do
      container[:test]
    end
  end

  def test_register
    container = new_container
    container.register( :test, :pipeline=>[] ) { Hash.new }

    assert_nothing_raised { container[:test] }
    assert_nothing_raised { container.test }

    assert_instance_of Hash, container[:test]
    assert_instance_of Hash, container.test

    assert container.respond_to?(:test)
  end

  def test_builder
    container = new_container
    b1 = container.builder
    b2 = container.builder

    assert_same b1.__id__, b2.__id__
  end

  def test_define_block
    container = new_container

    container.define do |b|
      b.test( :pipeline=>[] ) { Hash.new }
      b.namespace_define :subitem, :pipeline=>[] do |b2|
        b2.test2( :pipeline=>[] ) { Hash.new }
      end
    end

    assert container.has_key?( :test )
    assert_instance_of Hash, container.test
    assert container.subitem.has_key?( :test2 )
    assert_instance_of Hash, container.subitem.test2
  end

  def test_define_noblock
    container = new_container
    container.define.test( :pipeline=>[] ) { Hash.new }
    assert container.has_key?( :test )
    assert_instance_of Hash, container.test
  end

  def test_define!
    container = new_container

    container.define! do
      test( :pipeline=>[] ) { Hash.new }
      namespace! :subitem, :pipeline=>[] do
        test2( :pipeline=>[] ) { Hash.new }
      end
    end

    assert container.has_key?( :test )
    assert_instance_of Hash, container.test
    assert container.subitem.has_key?( :test2 )
    assert_instance_of Hash, container.subitem.test2
  end

  def test_namespace
    container = new_container
    container.namespace( :test, :pipeline=>[] )
    assert_instance_of Needle::Container, container.test

    container.namespace( :test2, :pipeline=>[] ) do |ns|
      assert_instance_of Needle::Container, ns
    end

    assert_instance_of Needle::Container, container.test2
  end

  def test_namespace_define
    container = new_container
    container.namespace_define( :test, :pipeline=>[] ) do |b|
      b.item( :pipeline=>[] ) { Hash.new }
    end
    assert container.has_key?( :test )
    assert container.test.has_key?( :item )
  end

  def test_namespace_define!
    container = new_container
    container.namespace_define!( :test, :pipeline=>[] ) do
      item( :pipeline=>[] ) { Hash.new }
    end
    assert container.has_key?( :test )
    assert container.test.has_key?( :item )
  end

  def test_namespace!
    container = new_container
    container.namespace!( :test, :pipeline=>[] ) do
      item( :pipeline=>[] ) { Hash.new }
    end
    assert container.has_key?( :test )
    assert container.test.has_key?( :item )
  end

  def test_has_key
    container = new_container

    assert !container.has_key?(:test)
    container.register( :test, :pipeline=>[] ) { Hash.new }
    assert container.has_key?(:test)
  end

  def test_knows_key
    container = new_container

    assert !container.knows_key?(:test)
    container.register( :test, :pipeline=>[] ) { Hash.new }
    assert container.knows_key?(:test)
  end

  def test_parent_knows_key
    outer = new_container
    inner = new_container( outer )

    outer.register( :test, :pipeline=>[] ) { Hash.new }
    assert !inner.has_key?(:test)
    assert inner.knows_key?(:test)
  end

  def test_services_from_child_available_to_parent_services
    outer = new_container
    inner = new_container( outer )

    outer.define do |b|
      b.override_me { "override_me" }
      b.use_override { |c, p| c.override_me.intern }
    end
    inner = Needle::Registry.define( :parent => outer ) do |b|
      b.override_me { "the_child_override" }
    end
    assert_same(:the_child_override, inner[:use_override])
  end

  def test_service_in_parent
    outer = new_container
    inner = new_container( outer )

    outer.register( :test, :pipeline=>[] ) { Hash.new }
    assert_nothing_raised do
      inner[:test]
    end
  end

  def test_service_not_in_parent
    outer = new_container
    inner = new_container( outer )

    assert_raise( Needle::ServiceNotFound ) do
      inner[:test]
    end
  end

  def test_intercept_not_found
    container = new_container
    assert_raise( Needle::ServiceNotFound ) do
      container.intercept( :test )
    end
  end

  def test_intercept
    container = new_container
    container.register( :test ) { Hash.new }

    filtered = false
    container.intercept( :test ).doing { |chain,ctx| filtered = true; chain.process_next(ctx) }

    assert !filtered
    svc = container.test
    svc[:hello] = :world
    assert filtered
  end

  def test_find_definition_missing
    container = new_container
    assert_nil container.find_definition( :bogus )
  end

  def test_find_definition_found_local
    container = new_container
    container.register( :test, :pipeline=>[] ) { Object.new }
    assert_not_nil container.find_definition( :test )
  end

  def test_find_definition_found_ancestor
    outer = new_container
    inner = new_container( outer )
    outer.register( :test, :pipeline=>[] ) { Object.new }
    assert_not_nil inner.find_definition( :test )
  end

  def test_pipeline
    container = new_container
    container.register( :test, :pipeline=>[] ) { Object.new }
    assert_instance_of Needle::Pipeline::Collection, container.pipeline( :test )

    p1 = container.pipeline(:test)
    p2 = container.pipeline(:test)
    assert_same p1, p2
  end

  def test_require_default
    container = new_container
    container.register( :service_models, :pipeline=>[] ) { Hash[ :singleton => [] ] }
    container.require( "services", "A::B::C" )
    
    assert_not_nil container[:foo]
    assert_not_nil container[:foo][:bar]
  end

  def test_require_custom
    container = new_container
    container.register( :service_models , :pipeline=>[] ) { Hash[ :singleton => [] ] }
    container.require( "services", "A::B::C", :register_other_services )
    
    assert_not_nil container[:blah]
    assert_not_nil container[:blah][:baz]
  end

  def test_custom_namespace_impl
    container = new_container
    container.namespace :subspace

    subspace = container.subspace
    subspace.register( :namespace_impl_factory ) { CustomContainer }
    subspace.namespace :custom_namespace
    ns = subspace.custom_namespace

    assert_instance_of Needle::Container, subspace
    assert_instance_of CustomContainer, ns
  end

  def test_custom_builder_impl
    container = new_container
    container.namespace :subspace

    subspace = container.subspace
    subspace.register( :definition_context_factory ) { CustomBuilder }

    assert_equal Needle::DefinitionContext, container.builder.class
    assert_equal CustomBuilder, subspace.builder.class
  end

  def test_custom_interceptor_impl
    container = new_container
    container.namespace :subspace

    subspace = container.subspace
    subspace.register( :interceptor_impl_factory ) { CustomInterceptor }

    assert_equal Needle::Interceptor, container.intercept( :logs ).class
    assert_equal CustomInterceptor, subspace.intercept( :logs ).class
  end

  def test_descended_from?
    outer = new_container
    middle = new_container( outer )
    inner = new_container( middle )
    assert inner.descended_from?( outer )
    assert inner.descended_from?( middle )
    assert inner.descended_from?( inner )
    assert !outer.descended_from?( inner )
  end

  def test_defaults_inherited
    root = new_container
    root.defaults[:hello] = :world
    c1   = new_container( root )
    assert_equal :world, c1.defaults[:hello]
    root.defaults[:hello] = :jisang
    assert_equal :world, c1.defaults[:hello]
  end

  def test_defaults_used
    root = new_container
    root.define.foo { Object.new }
    root.defaults[:model] = :prototype
    root.define.bar { Object.new }
    f1 = root.foo
    f2 = root.foo
    assert_same f1, f2
    b1 = root.bar
    b2 = root.bar
    assert_not_same b1, b2
  end

  def test_use_bang_without_block
    root = new_container
    original = root.use! :model => :prototype
    assert original.empty?
    o2 = root.use! :pipeline => [ :threaded ]
    assert_nil root.defaults[:model]
    assert_equal [ :threaded ], root.defaults[:pipeline]
    root.use! o2
    assert_nil root.defaults[:pipeline]
    assert_equal :prototype, root.defaults[:model]
  end

  def test_use_bang_with_block
    root = new_container
    root.use! :model => :prototype do |r|
      assert_same root, r
      assert_equal :prototype, root.defaults[:model]
      root.use! :pipeline => [ :threaded ] do
        assert_nil root.defaults[:model]
        assert_equal [ :threaded ], root.defaults[:pipeline]
      end
      assert_nil root.defaults[:pipeline]
      assert_equal :prototype, root.defaults[:model]
    end
    assert_nil root.defaults[:model]
  end

  def test_use_without_block
    root = new_container
    o1 = root.use :model => :prototype
    o2 = root.use :pipeline => [ :threaded ]
    assert_equal :prototype, root.defaults[:model]
    assert_equal [ :threaded ], root.defaults[:pipeline]
  end

  def test_use_with_block
    root = new_container
    root.use :model => :prototype do |r|
      assert_same root, r
      assert_equal :prototype, root.defaults[:model]
      root.use :pipeline => [ :threaded ] do
        assert_equal :prototype, root.defaults[:model]
        assert_equal [ :threaded ], root.defaults[:pipeline]
      end
      assert_nil root.defaults[:pipeline]
      assert_equal :prototype, root.defaults[:model]
    end
    assert_nil root.defaults[:model]
  end

end
