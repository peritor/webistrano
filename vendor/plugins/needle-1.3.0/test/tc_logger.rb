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

require 'needle/log-factory'
require 'test/unit'
require 'stringio'

class TC_Logger < Test::Unit::TestCase

  class MockLogIO
    attr_reader :message

    def initialize
      clear
    end

    def write( message )
      @message << message << "\n"
    end

    def clear
      @message = ""
    end

    def close
      @message = "<closed>"
    end
  end

  def teardown
    logs = Dir[File.join(File.dirname(__FILE__),"*.log")]
    File.delete( *logs ) unless logs.empty?
  end

  def test_log_filename
    factory = Needle::LogFactory.new
    assert_equal Needle::LogFactory::DEFAULT_LOG_FILENAME,
                 factory.device.filename
    factory.close
    assert factory.closed?

    factory = Needle::LogFactory.new :filename => './sample.log'
    assert_equal "./sample.log", factory.device.filename
    factory.close

    factory = Needle::LogFactory.new :device => STDOUT
    assert_equal STDOUT, factory.device
    factory.close

    assert !STDOUT.closed?
  end

  def test_log_options
    factory = Needle::LogFactory.new :default_date_format => "%Y",
                                      :default_level => Logger::FATAL
    assert_equal "%Y", factory.default_date_format
    assert_equal Logger::FATAL, factory.default_level
    factory.close
  end

  def test_log_bad_option
    assert_raise( ArgumentError ) do
      Needle::LogFactory.new :bogus => "hello"
    end
  end

  def test_bad_log_level_option
    assert_raise( ArgumentError ) do
      Needle::LogFactory.new :levels => { "test.*" => { :bogus => 5 } }
    end
  end

  def test_log_config_via_yaml
    require 'yaml'
    config = YAML.load( <<-EOF )
      ---
      filename: ./somewhere.log
      roll-age: 5
      roll-size: 10241024
      default-date-format: "%Y-%m-%d %H:%M:%S"
      default-message-format: "[%d] %C - %m"
      default-level: WARN
      levels:
        test.*: INFO
        verbose.*:
          level: WARN
          date-format: "%Y-%m-%d"
          message-format: "%C - %m"
    EOF
    assert_nothing_raised do
      Needle::LogFactory.new config
    end
  end

  def test_log_get
    factory = Needle::LogFactory.new

    log1a = factory.get( "test.log1" )
    log2  = factory.get( "test.log2" )
    log1b = factory.get( "test.log1" )

    assert_equal log1a.object_id, log1b.object_id
    assert_not_equal log1a.object_id, log2.object_id

    factory.close
  end

  def test_log_write
    io = MockLogIO.new
    factory = Needle::LogFactory.new(
      :device => io,
      :levels => {
        "test.*" => :INFO
      } )

    log = factory.get( "test.log1" )

    # the factory has DEBUG turned off...
    log.debug "test"
    assert_equal "", io.message

    log.info "test"
    assert_match( /\[INFO \] .* -- test.log1: test/, io.message )

    factory.close
    assert_equal "<closed>", io.message
  end

  def test_levels
    io = MockLogIO.new
    factory = Needle::LogFactory.new :device => io,
                  :levels => {
                    "level.*" => :WARN,
                    "level.test.*" => :DEBUG
                  }

    log = factory.get( "level.log1" )

    log.info "test"
    assert_equal "", io.message

    log = factory.get( "level.test.log1" )

    log.debug "test"
    assert_match( /\[DEBUG\] .* -- level.test.log1: test/, io.message )

    factory.close
  end

  def test_message_format
    io = MockLogIO.new
    factory = Needle::LogFactory.new :device => io,
                :default_message_format => "%c %C [%-5p] %F %m %M %t %% %$"

    log = factory.get( "message.log1" )
    log.info "test"
    assert_match(
      /log1 message.log1 \[INFO \] \S*tc_logger.rb test test_message_format #{Thread.current.__id__} % #{$$}\n/,
      io.message
    )
  end

  def test_logger_write_to
    io = StringIO.new
    io2 = StringIO.new

    factory = Needle::LogFactory.new :device => io,
                :default_message_format => "%m"

    log = factory.get( "test.write-to" )
    log.info "test"
    log.info "another"
    assert_match( /\Atest\nanother/, io.string )

    log.write_to io2
    log.info "howdy"
    assert_match( /\Atest/, io.string )
    assert_match( /\Ahowdy/, io2.string )
  end

  def test_log_factory_write_to
    io = StringIO.new
    io2 = StringIO.new

    factory = Needle::LogFactory.new :device => io,
                :default_message_format => "%m"

    log1 = factory.get( "test.write-to" )
    log2 = factory.get( "test.write-to2" )

    log1.info "test"
    log2.info "another"

    assert_match( /\Atest\nanother/, io.string )

    factory.write_to io2
    assert io.closed?

    log1.info "howdy"
    log2.info "world"

    assert_match( /\Ahowdy\nworld/, io2.string )
  end

end
