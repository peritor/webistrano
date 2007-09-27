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

require '02/tc_packet_assistant'
require 'net/sftp/protocol/03/packet-assistant'

class TC_03_PacketAssistant < TC_02_PacketAssistant

  def packet_assistant_class
    Net::SFTP::Protocol::V_03::PacketAssistant
  end

  packet :readlink, [ "a path" ], "\0\0\0\6a path"

  packet :symlink, [ "from path", "to path" ],
    "\0\0\0\11from path\0\0\0\7to path"

end
