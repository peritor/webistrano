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
require 'net/sftp/operations/readdir'
require 'flexmock'

class TC_Operations_Readdir < Test::Unit::TestCase

  def setup
    @log = FlexMock.new
    @session = FlexMock.new
    @driver = FlexMock.new
    @operation = Net::SFTP::Operations::Readdir.new( @log, @session, @driver )
  end

  def test_perform
    id = handle = nil
    @driver.mock_handle( :readdir ) { |i,h| id, handle = i, h; 10 }
    assert_equal 10, @operation.perform( "foo" )
    assert_nil id
    assert_equal "foo", handle
  end

  def test_do_name
    id = handle = nil
    @log.mock_handle( :debug? )
    @log.mock_handle( :debug )
    @driver.mock_handle( :readdir ) { |i,h| id, handle = i, h; 10 }
    @session.mock_handle( :register )
    @operation.perform( "foo" )
    @operation.do_name( [ :a, :b ] )
    assert_equal 1, @session.mock_count( :register )
    assert_equal "foo", handle
  end

  def test_do_status_ok
    called = false

    @log.mock_handle( :debug? )
    @log.mock_handle( :debug )
    @driver.mock_handle( :readdir )
    @session.mock_handle( :register )
    @session.mock_handle( :status= )
    @session.mock_handle( :loop )

    @operation.execute( "foo" ) { called = true }
    assert_nothing_raised { @operation.do_status( 0, :a, :b ) }
    assert called
  end

  def test_do_status_eof
    called = false

    @log.mock_handle( :debug? )
    @log.mock_handle( :debug )
    @driver.mock_handle( :readdir )
    @session.mock_handle( :register )
    @session.mock_handle( :status= )
    @session.mock_handle( :loop )

    @operation.execute( "foo" ) { called = true }
    assert_nothing_raised { @operation.do_status( 1, :a, :b ) }
    assert called
  end

  def test_do_status_bad
    assert_raise( Net::SFTP::Operations::StatusException ) do
      @operation.do_status( 2, :a, :b )
    end
  end

end
