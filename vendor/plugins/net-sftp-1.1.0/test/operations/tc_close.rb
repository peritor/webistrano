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
require 'net/sftp/operations/close'
require 'flexmock'

class TC_Operations_Close < Test::Unit::TestCase

  def setup
    @log = FlexMock.new
    @session = FlexMock.new
    @driver = FlexMock.new
    @operation = Net::SFTP::Operations::Close.new( @log, @session, @driver )
  end

  def test_perform
    id = handle = nil
    @driver.mock_handle( :close_handle ) { |i,h| id, handle = i, h; 10 }
    assert_equal 10, @operation.perform( "foo" )
    assert_nil id
    assert_equal "foo", handle
  end

end
