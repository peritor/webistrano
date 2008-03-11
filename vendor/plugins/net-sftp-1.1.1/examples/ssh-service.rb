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

$:.unshift "../lib"
require 'net/ssh'
require 'net/sftp'

Net::SSH.start( 'localhost' ) do |session|
  session.sftp.connect do |sftp|
    h = sftp.opendir( "." )
    sftp.readdir( h ).sort { |a,b| a.filename <=> b.filename }.each do |item|
      puts "%06o %6d %-20s" %
        [ item.attributes.permissions, item.attributes.size, item.filename ]
    end
    sftp.close_handle( h )
  end
end
