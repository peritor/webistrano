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

require '03/tc_packet_assistant'
require 'net/sftp/protocol/04/packet-assistant'

class TC_04_PacketAssistant < TC_03_PacketAssistant

  def packet_assistant_class
    Net::SFTP::Protocol::V_04::PacketAssistant
  end

  packet :rename, [ "old name", "new name", 1 ],
    "\0\0\0\10old name\0\0\0\10new name\0\0\0\1"

  packet :stat, [ "a path", 1 ], "\0\0\0\6a path\0\0\0\1"

  packet :lstat, [ "a path", 1 ], "\0\0\0\6a path\0\0\0\1"

  packet :fstat, [ "handle", 1 ], "\0\0\0\6handle\0\0\0\1"

end
