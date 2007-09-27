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
require 'net/sftp/operations/setstat'
require 'flexmock'

class TC_Operations_setstat < Test::Unit::TestCase

  def setup
    @log = FlexMock.new
    @session = FlexMock.new
    @attr_factory = FlexMock.new
    @driver = FlexMock.new
    @driver.mock_handle( :attr_factory ) { @attr_factory }
    @operation = Net::SFTP::Operations::Setstat.new( @log, @session, @driver )
  end

  def test_perform
    hash = nil
    @attr_factory.mock_handle( :from_hash ) { |h| hash = h; :foo }

    id = path = attrs = nil
    @driver.mock_handle( :setstat ) { |i,p,a| id, path, attrs = i, p, a; 10 }

    assert_equal 10, @operation.perform( "foo", "bar" )
    assert_nil id
    assert_equal "foo", path
    assert_equal "bar", hash
    assert_equal :foo, attrs
  end

end
