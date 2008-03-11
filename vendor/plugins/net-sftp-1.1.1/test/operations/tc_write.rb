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
require 'net/sftp/operations/write'
require 'flexmock'

class TC_Operations_Write < Test::Unit::TestCase

  def setup
    @log = FlexMock.new
    @log.mock_handle( :debug? )
    @log.mock_handle( :debug )

    @session = FlexMock.new
    @driver = FlexMock.new
    @operation = Net::SFTP::Operations::Write.new( @log, @session, @driver )
  end

  def test_perform_defaults
    id = handle = offset = data = nil
    @driver.mock_handle( :write ) { |i,h,o,d| id, handle, offset, data = i, h, o, d; 10 }
    assert_equal 10, @operation.perform( "foo", "data" )
    assert_nil id
    assert_equal "foo", handle
    assert_equal "data", data
    assert_equal 0, offset
  end

  def test_perform_explicit
    id = handle = offset = data = nil
    @driver.mock_handle( :write ) { |i,h,o,d| id, handle, offset, data = i, h, o, d; 10 }
    assert_equal 10, @operation.perform( "foo", "data", 15 )
    assert_nil id
    assert_equal "foo", handle
    assert_equal "data", data
    assert_equal 15, offset
  end

  def test_do_status_bad
    assert_raise( Net::SFTP::Operations::StatusException ) do
      @operation.do_status( 5, nil, nil )
    end
  end

  def test_do_status_ok_more_chunks
    @log.mock_handle :debug?
    @log.mock_handle :debug
    @session.mock_handle :register
    @session.mock_handle :status=
    @session.mock_handle :loop
    @driver.mock_handle :write

    @operation.execute( "foo", "1234567890" * 7000 )
    @operation.do_status( 0, :a, :b )
    assert_equal 2, @driver.mock_count( :write )
    assert_equal 2, @session.mock_count( :register )
  end

  def test_do_status_ok_done
    @log.mock_handle :debug?
    @log.mock_handle :debug
    @session.mock_handle :register
    @session.mock_handle :status=
    @session.mock_handle :loop
    @driver.mock_handle :write

    called = false
    @operation.execute( "foo", "1234567890" ) { called = true }
    @operation.do_status( 0, :a, :b )
    assert_equal 1, @driver.mock_count( :write )
    assert_equal 1, @session.mock_count( :register )
    assert called
  end

end
