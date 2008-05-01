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

Net::SSH.start( 'localhost' ) do |session|

  shell = session.shell.open

  # script what we want to do
  shell.pwd
  shell.cd "/"
  shell.pwd
  shell.test "-e foo"
  shell.ls "-laZ"
  shell.cd "/really/bogus/directory"
  shell.send_data "/sbin/ifconfig\n"
  shell.pwd
  shell.ruby "-v"
  shell.cd "/usr/lib"
  shell.pwd
  shell.exit

  # give the above commands sufficient time to terminate
  sleep 0.5

  # display the output
  $stdout.print shell.stdout while shell.stdout?
  $stderr.puts "-- stderr: --"
  $stderr.print shell.stderr while shell.stderr?

end
