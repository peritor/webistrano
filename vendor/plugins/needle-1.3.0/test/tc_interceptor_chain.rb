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

require 'needle/interceptor-chain'
require 'test/unit'
require 'ostruct'

class TC_InterceptorChainElement < Test::Unit::TestCase

  class Interceptor
    attr_reader :next_obj
    attr_reader :context

    def process( next_obj, context )
      @next_obj = next_obj
      @context = context
    end
  end

  def test_process_next
    interceptor = Interceptor.new
    element =
      Needle::InterceptorChainBuilder::InterceptorChainElement.new interceptor

    element.next = :next_obj
    element.process_next :context

    assert_equal :next_obj, interceptor.next_obj
    assert_equal :context, interceptor.context
  end

end

class TC_ProxyObjectChainElement < Test::Unit::TestCase

  Context = Struct.new( :sym, :args, :block )

  class ProxyObject
    attr_reader :args
    attr_reader :value

    def invoke( *args, &block )
      @args = args
      @value = block.call
    end
  end

  def test_process_next
    obj = ProxyObject.new
    element = Needle::InterceptorChainBuilder::ProxyObjectChainElement.new obj
    ctx = Context.new( :invoke, [ 1, 2, 3 ], proc { "value" } )
    element.process_next( ctx )

    assert_equal [ 1, 2, 3 ], obj.args
    assert_equal "value", obj.value
  end

end

class TC_InterceptorChainBuilder < Test::Unit::TestCase

  class Interceptor
    def initialize( point, opts, name=nil )
      @opts = opts
      @name = name
    end

    def process( chain, context )
      @opts[:hash][:chain] << @opts[:name]
      @opts[:hash][:sym] = context.sym
      @opts[:hash][:args] = context.args.length
      @opts[:hash][:has_block] = !context.block.nil?
      chain.process_next( context )
    end
  end

  def setup
    @point = OpenStruct.new
  end

  def test_nil
    service = Object.new
    service2 = Needle::InterceptorChainBuilder.build( @point, service, nil )
    assert_same service, service2
  end

  def test_none
    service = Object.new
    service2 = Needle::InterceptorChainBuilder.build( @point, service, [] )
    assert_same service, service2
  end

  def test_one
    service = Hash.new
    data = { :chain=>[] }
    interceptors = [
      OpenStruct.new( :action=>proc { Interceptor },
        :options=> { :hash=>data } )
    ]

    service2 = Needle::InterceptorChainBuilder.build( @point, service, interceptors )

    assert_instance_of(
      Needle::InterceptorChainBuilder::InterceptedServiceProxy, service2 )

    service2.length
    assert_equal :length, data[:sym]
    assert_equal 0, data[:args]
    assert !data[:has_block]

    service2[:hello] = :something
    assert_equal :[]=, data[:sym]
    assert_equal 2, data[:args]
    assert !data[:has_block]

    service2.each_key { |k| }
    assert_equal :each_key, data[:sym]
    assert_equal 0, data[:args]
    assert data[:has_block]
  end

  def test_many
    service = Hash.new
    chain = []
    data = Array.new( 4 ) { { :chain=>chain } }
    interceptors = [
      OpenStruct.new( :action=>proc { Interceptor },
        :options=>{ :hash=>data[0], :priority=>5, :name=>"A" } ),
      OpenStruct.new( :action=>proc { Interceptor },
        :options=>{ :hash=>data[1], :priority=>3, :name=>"B" } ),
      OpenStruct.new( :action=>proc { Interceptor },
        :options=>{ :hash=>data[2], :priority=>7, :name=>"C" } ),
      OpenStruct.new( :action=>proc { Interceptor },
        :options=>{ :hash=>data[3], :priority=>5, :name=>"D" } )
    ]

    service2 = Needle::InterceptorChainBuilder.build( @point, service, interceptors )
    expect_chain = [ "B", "A", "D", "C" ]

    service2.length
    4.times do |i|
      assert_equal :length, data[i][:sym]
      assert_equal 0, data[i][:args]
      assert !data[i][:has_block]
    end
    assert_equal expect_chain, chain
    chain.clear

    service2[:hello] = :something
    4.times do |i|
      assert_equal :[]=, data[i][:sym]
      assert_equal 2, data[i][:args]
      assert !data[i][:has_block]
    end
    assert_equal expect_chain, chain
    chain.clear

    service2.each_key { |k| }
    4.times do |i|
      assert_equal :each_key, data[i][:sym]
      assert_equal 0, data[i][:args]
      assert data[i][:has_block]
    end
    assert_equal expect_chain, chain
  end
end
