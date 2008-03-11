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

$:.unshift "../../../lib"
$:.unshift File.join( File.dirname( __FILE__ ), ".." )

require '01/tc_impl.rb'
require 'net/sftp/protocol/02/impl'

class TC_02_Impl < TC_01_Impl

  def impl_class
    Net::SFTP::Protocol::V_02::Impl
  end

  operation :rename, :rename_raw

  def test_rename_flags
    @assistant.mock_handle( :rename ) { |*a| [ a[0], a[1..-1] ] }
    id = @impl.rename( 14, :a, :b, :c )
    assert_equal 14, id
    assert_equal 1, @assistant.mock_count( :rename )
    assert_equal 1, @driver.mock_count( :send_data )
    assert_equal [
      [ Net::SFTP::Protocol::Constants::FXP_RENAME, [ :a, :b ]] ], @sent_data
  end

end
