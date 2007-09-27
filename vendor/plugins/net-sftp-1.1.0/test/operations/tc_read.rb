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
require 'net/sftp/operations/read'
require 'flexmock'

class TC_Operations_Read < Test::Unit::TestCase

  def setup
    @log = FlexMock.new
    @log.mock_handle( :debug? )
    @log.mock_handle( :debug )

    @session = FlexMock.new
    @driver = FlexMock.new
    @operation = Net::SFTP::Operations::Read.new( @log, @session, @driver )
  end

  def test_perform_defaults
    id = handle = offset = length = nil
    @driver.mock_handle( :read ) { |i,h,o,l| id, handle, offset, length = i, h, o, l; 10 }
    assert_equal 10, @operation.perform( "foo" )
    assert_nil id
    assert_equal "foo", handle
    assert_equal 0, offset
    assert_equal 64 * 1024, length
  end

  def test_perform_explicit
    id = handle = offset = length = nil
    @driver.mock_handle( :read ) { |i,h,o,l| id, handle, offset, length = i, h, o, l; 10 }
    assert_equal 10, @operation.perform( "foo", :offset=>15, :length=>72 )
    assert_nil id
    assert_equal "foo", handle
    assert_equal 15, offset
    assert_equal 72, length
  end

  def test_do_data_full
    id = handle = offset = length = nil
    @driver.mock_handle( :read ) { |i,h,o,l| id, handle, offset, length = i, h, o, l; 10 }
    @session.mock_handle( :register )
    @operation.perform( "foo" )
    @operation.do_data( "harbinger of doom" )
    assert_equal 2, @driver.mock_count( :read )
    assert_equal 1, @session.mock_count( :register )
    assert_equal "foo", handle
    assert_equal 17, offset
    assert_equal 64 * 1024, length
  end

  def test_do_data_partial
    id = handle = offset = length = nil
    @driver.mock_handle( :read ) { |i,h,o,l| id, handle, offset, length = i, h, o, l; 10 }
    @session.mock_handle( :register )
    @session.mock_handle( :loop )
    @session.mock_handle( :status= )
    called = false
    @operation.execute( "foo", :offset=>15, :length=>20 ) { called = true }
    @operation.do_data( "harbinger of doom" )
    @operation.do_data( "abc" )
    assert_equal 2, @driver.mock_count( :read )
    assert_equal 2, @session.mock_count( :register )
    assert_equal "foo", handle
    assert_equal 32, offset
    assert_equal 3, length
    assert called
  end

  def test_do_status_eof
    @driver.mock_handle( :read )
    @session.mock_handle( :register )
    @session.mock_handle( :loop )
    @session.mock_handle( :status= )
    called = false
    @operation.execute( "foo", :offset=>15, :length=>20 ) { called = true }
    assert_nothing_raised { @operation.do_status( 1, nil, nil ) }
    assert called
  end

  def test_do_status_bad
    assert_raise( Net::SFTP::Operations::StatusException ) do
      @operation.do_status( 2, nil, nil )
    end
  end

end
