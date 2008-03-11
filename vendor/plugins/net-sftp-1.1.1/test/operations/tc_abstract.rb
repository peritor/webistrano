#--
# =============================================================================
# Copyright (c) 2004, Jamis Buck (jamis@37signals.com)
# All rights reserved.
#
# This source file is distributed as part of the Net::SFTP Secure FTP Client
# library for Ruby. This file (and the library as a whole) may be used only as
# allowed by either the BSD license, or the Ruby license (or, by association
# with the Ruby license, the GPL). See the "doc" subdirectory of the Net::SFTP
# distribution for the texts of these licenses.
# -----------------------------------------------------------------------------
# net-sftp website: http://net-ssh.rubyforge.org/sftp
# project website : http://rubyforge.org/projects/net-ssh
# =============================================================================
#++

$:.unshift "../../lib"

require 'test/unit'
require 'net/sftp/operations/abstract'
require 'flexmock'

class TC_Operations_Abstract < Test::Unit::TestCase

  class Subclass < Net::SFTP::Operations::Abstract
    attr_reader :args

    def perform( *args )
      @args = args
      14
    end
  end

  def setup
    @log = FlexMock.new
    @log.mock_handle( :debug )
    @log.mock_handle( :debug? )

    @session = FlexMock.new
    @session.mock_handle( :status= )
    @session.mock_handle( :register )
    @session.mock_handle( :loop )

    @driver = FlexMock.new

    @operation = Subclass.new( @log, @session, @driver )
  end

  def test_execute_no_block
    reg_args = nil
    @session.mock_handle( :register ) { |*a| reg_args = a }

    @operation.execute( :foo, :bar )

    assert_equal 1, @session.mock_count( :register )
    assert_equal 1, @session.mock_count( :loop )
    assert_equal [ 14, @operation ], reg_args
    assert_equal [ :foo, :bar ], @operation.args
  end

  def test_execute_with_block
    reg_args = nil
    @session.mock_handle( :register ) { |*a| reg_args = a }

    @operation.execute( :foo, :bar )  { }

    assert_equal 1, @session.mock_count( :register )
    assert_equal 0, @session.mock_count( :loop )
    assert_equal [ 14, @operation ], reg_args
    assert_equal [ :foo, :bar ], @operation.args
  end

  def test_do_status_bad
    assert_raise( Net::SFTP::Operations::StatusException ) do
      @operation.do_status( 5, nil, nil )
    end
  end

  def test_status_ok
    status = nil
    @operation.execute( :foo, :bar ) { |s| status = s }
    assert_nothing_raised { @operation.do_status( 0, "hello", "world" ) }
    assert_equal 0, status.code
    assert_equal "hello", status.message
    assert_equal "world", status.language
  end

  def test_do_handle
    status = nil
    handle = nil
    @operation.execute( :foo, :bar ) { |s,h| status, handle = s, h }
    @operation.do_handle( "foo" )
    assert_equal 0, status.code
    assert_equal "foo", handle
  end

  def test_do_data
    status = nil
    data = nil
    @operation.execute( :foo, :bar ) { |s,d| status, data = s, d }
    @operation.do_data( "foo" )
    assert_equal 0, status.code
    assert_equal "foo", data
  end

  def test_do_name
    status = nil
    name = nil
    @operation.execute( :foo, :bar ) { |s,n| status, name = s, n }
    @operation.do_name( "foo" )
    assert_equal 0, status.code
    assert_equal "foo", name
  end

  def test_do_attrs
    status = nil
    attrs = nil
    @operation.execute( :foo, :bar ) { |s,a| status, attrs = s, a }
    @operation.do_attrs( "foo" )
    assert_equal 0, status.code
    assert_equal "foo", attrs
  end

end
