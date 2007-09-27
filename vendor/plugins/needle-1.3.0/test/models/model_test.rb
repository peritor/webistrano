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

class ModelTest_MockService
  attr_reader :init_result

  def initialize
    @init_result = :none
  end

  def initialize_service
    @init_result = :initialized
  end

  def custom_init
    @init_result = :custom
  end

end

module ModelTest

  def self.append_features( base )
    super
    base.extend ClassFeatures
  end

  module ClassFeatures
    attr_reader :model

    def use( model )
      @model = model
    end

    def assert_prototype
      define_method( :test_multiplicity ) do
        o1 = @registry[ :test ]
        o2 = @registry[ :test ]
        assert_not_same o1, o2
      end
    end

    def assert_singleton
      define_method( :test_multiplicity ) do
        o1 = @registry[ :test ]
        o2 = @registry[ :test ]
        assert_same o1, o2
      end
    end

    def assert_threaded
      define_method( :extra_setup ) do
        cache = Thread.current[:threaded_services]
        cache.delete "test" if cache
      end

      define_method( :test_multiplicity_singlethread ) do
        @registry[ :test ].init_result
        @registry[ :test ].init_result
        @registry[ :test ].init_result
        assert_equal 1, @count 
      end

      define_method( :test_multiplicity_multithread ) do
        threads = []
        threads << Thread.new { @registry[ :test ].init_result }
        threads << Thread.new { @registry[ :test ].init_result }
        threads << Thread.new { @registry[ :test ].init_result }
        threads.each { |t| t.join }
        assert_equal 3, @count 
      end
    end

    def assert_immediate
      define_method( :test_laziness ) do
        @registry[ :test ]
        assert_equal 1, @count 
      end
    end

    def assert_deferred
      define_method( :test_laziness ) do
        o = @registry[ :test ]
        assert_equal 0, @count
        o.init_result
        assert_equal 1, @count
      end
    end

    def assert_no_init
      define_method( :test_initialize ) do
        o = @registry[ :test ]
        assert_equal :none, o.init_result
      end
    end

    def assert_init
      if instance_methods.include?( "extra_setup" )
        save_setup = instance_method( :extra_setup )
      end

      define_method( :extra_setup ) do
        save_setup.bind( self ).call if save_setup
        @registry.register( :test_init, :model=>self.class.model,
          :init_method=>:custom_init
        ) { ModelTest_MockService.new }
      end

      define_method( :test_initialize ) do
        o = @registry[ :test ]
        assert_equal :initialized, o.init_result
      end

      define_method( :test_custom_initialize ) do
        o = @registry[ :test_init ]
        assert_equal :custom, o.init_result
      end
    end
  end

  def setup
    @count = 0
    @registry = Needle::Registry.new do |r|
      r.register :test, :model => self.class.model do 
        @count += 1
        ModelTest_MockService.new
      end
    end

    extra_setup if respond_to?( :extra_setup )
  end

end
