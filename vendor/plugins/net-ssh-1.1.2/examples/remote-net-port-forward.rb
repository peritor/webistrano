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

# This assumes four things:
#
# 1) That you have an SSH server running on your local machine,
# 2) That the USER environment variable is set to your user name, and
# 3) That you have public and private keys conigured so that you can log into
#    your machine via SSH without being prompted for a password.
# 4) That you have a web server running on your local machine on port 80.
#
# If #2 or #3 are not true, you can add your user-name and password as the
# second and third parameters (respectively) to Net::SSH.start.

Net::SSH.start( 'localhost' ) do |session|
  session.forward.remote_to( 80, "localhost", 12345 )

  trap("SIGINT") { session.close }

  begin
    puts "forwarding remote port via localhost..."
    session.loop { true }
  rescue Exception => e
    unless e.message =~ /connection closed by remote host/
      raise
    end
  end
end
