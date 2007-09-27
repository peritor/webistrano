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

require 'needle/interceptor'
require 'test/unit'

class TC_Interceptor < Test::Unit::TestCase

  def test_empty
    i = Needle::Interceptor.new
    assert_equal [ :priority ], i.options.keys
    assert_equal 0, i.options[:priority]
  end

  def test_missing_action
    i = Needle::Interceptor.new

    assert_raise( Needle::InterceptorConfigurationError ) do
      i.action
    end
  end

  def test_with_redefined
    i = Needle::Interceptor.new

    assert_raise( Needle::InterceptorConfigurationError ) do
      i.with { :a }.with { :a }
    end
  end

  def test_doing_redefined
    i = Needle::Interceptor.new

    assert_raise( Needle::InterceptorConfigurationError ) do
      i.doing { :a }.doing { :a }
    end
  end

  def test_with_doing
    i = Needle::Interceptor.new

    assert_raise( Needle::InterceptorConfigurationError ) do
      i.with { :a }.doing { :a }
    end
  end

  def test_doing_with
    i = Needle::Interceptor.new

    assert_raise( Needle::InterceptorConfigurationError ) do
      i.doing { :a }.with { :a }
    end
  end

  def test_options
    i = Needle::Interceptor.new.
      with_options(
        :priority => 5,
        :exclude => [ /^__/ ],
        :include => [ /^__foo/ ] )

    assert_equal 5, i[:priority]
    assert_equal [ /^__/ ], i[:exclude]
    assert_equal [ /^__foo/ ], i[:include]
  end

  def test_with
    i = Needle::Interceptor.new.with { |c| Hash.new }
    assert_instance_of Hash, i.action.call(nil)
  end

  def test_doing
    i = Needle::Interceptor.new.doing { |ch,ctx| ch.process_next(ctx) }
    assert_instance_of Needle::Interceptor::DynamicInterceptor, i.action.call(nil)
  end

end
