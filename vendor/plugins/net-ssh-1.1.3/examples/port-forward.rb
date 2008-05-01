#--
# =============================================================================
# Copyright (c) 2004,2005 Jamis Buck (jamis@37signals.com)
# All rights reserved.
#
# This source file is distributed as part of the Net::SSH Secure Shell Client
# library for Ruby. This file (and the library as a whole) may be used only as
# allowed by either the BSD license, or the Ruby license (or, by association
# with the Ruby license, the GPL). See the "doc" subdirectory of the Net::SSH
# distribution for the texts of these licenses.
# -----------------------------------------------------------------------------
# net-ssh website : http://net-ssh.rubyforge.org
# project website: http://rubyforge.org/projects/net-ssh
# =============================================================================
#++

$:.unshift "../lib"

require 'net/ssh'

# This assumes three things:
#
# 1) That you have an SSH server running on your local machine,
# 2) That the USER environment variable is set to your user name, and
# 3) That you have public and private keys conigured so that you can log into
#    your machine via SSH without being prompted for a password.
#
# If #2 or #3 are not true, you can add your user-name and password as the
# second and third parameters (respectively) to Net::SSH.start.

Net::SSH.start( 'localhost' ) do |session|
  session.forward.local( 12345, 'www.yahoo.com', 80 )
  session.forward.local( 12346, 'www.google.com', 80 )

  trap("SIGINT") do
    puts "direct channels open  : #{session.forward.open_direct_channel_count}"
    puts "direct channels opened: #{session.forward.direct_channel_count}"
    puts "active local forwards : #{session.forward.active_locals.length} " +
      "(#{session.forward.active_locals.inspect})"
    session.close
  end

  begin
    puts "forwarding ports..."
    session.loop { true }
  rescue Exception => e
    unless e.message =~ /connection closed by remote host/
      raise
    end
  end
end
