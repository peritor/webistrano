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

require '02/tc_impl.rb'
require 'net/sftp/protocol/03/impl'

class TC_03_Impl < TC_02_Impl

  def impl_class
    Net::SFTP::Protocol::V_03::Impl
  end

  operation :readlink

  operation :symlink

  def test_do_status_with_callback
    buffer = Net::SSH::Util::ReaderBuffer.new( "\0\0\0\1\0\0\0\2" +
      "\0\0\0\1a\0\0\0\1b" )
    called = false
    @impl.on_status do |d,i,c,a,b|
      called = true
      assert_equal 1, i
      assert_equal 2, c
      assert_equal "a", a
      assert_equal "b", b
    end
    @impl.do_status nil, buffer
    assert called
  end

end
