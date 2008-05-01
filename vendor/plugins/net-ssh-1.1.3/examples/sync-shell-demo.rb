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

  shell = session.shell.sync

  out = shell.pwd
  p out.stdout

  out = shell.cd "/"

  out = shell.pwd
  p out.stdout

  out = shell.test "-e foo"
  p out.status

  out = shell.ls "-laZ"
  p out.stderr
  p out.status

  out = shell.cd "/really/bogus/directory"
  p out.stderr
  p out.status

  out = shell.send_command "/sbin/ifconfig"
  p out.stdout
  p out.status

  out = shell.pwd
  p out.stdout

  out = shell.ruby "-v"
  p out.stdout

  out = shell.cd "/usr/lib"

  out = shell.pwd
  p out.stdout

  out = shell.send_command( "bc", <<CMD )
5+5
10*2
scale=5
3/4
quit
CMD
  p out.stdout

  p shell.exit

end
