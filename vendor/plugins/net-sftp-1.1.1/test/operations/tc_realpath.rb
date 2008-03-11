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
require 'net/sftp/operations/realpath'
require 'flexmock'

class TC_Operations_Realpath < Test::Unit::TestCase

  def setup
    @log = FlexMock.new
    @session = FlexMock.new
    @driver = FlexMock.new
    @operation = Net::SFTP::Operations::Realpath.new( @log, @session, @driver )
  end

  def test_perform
    id = path = nil
    @driver.mock_handle( :realpath ) { |i,p| id, path = i, p; 10 }
    assert_equal 10, @operation.perform( "foo" )
    assert_nil id
    assert_equal "foo", path
  end

  def test_do_name
    @session.mock_handle( :loop )
    @session.mock_handle( :status= )
    @session.mock_handle( :register )
    @driver.mock_handle( :realpath )
    @log.mock_handle( :debug? )
    @log.mock_handle( :debug )

    called = false
    @operation.execute( "foo" ) { |s,v| called = v }
    @operation.do_name( [ :a, :b ] )
    assert_equal :a, called
  end

end
