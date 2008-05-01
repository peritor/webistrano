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

# This is a (very) simple, but capable, SSH terminal client. It DOES NOT send
# the size of the terminal window, or handle resizing of the terminal window.

$:.unshift "../lib"
require 'net/ssh'

begin
  require 'termios'
rescue LoadError
end

def stdin_buffer( enable )
  return unless defined?( Termios )
  attr = Termios::getattr( $stdin )
  if enable
    attr.c_lflag |= Termios::ICANON | Termios::ECHO
  else
    attr.c_lflag &= ~(Termios::ICANON|Termios::ECHO)
  end
  Termios::setattr( $stdin, Termios::TCSANOW, attr )
end

host = ARGV.shift or abort "You must specify the [user@]host to connect to"
if host =~ /@/
  user, host = host.match( /(.*?)@(.*)/ )[1,2]
else
  user = ENV['USER'] || ENV['USER_NAME']
end

Net::SSH.start( host, user ) do |session|

  begin
    stdin_buffer false

    shell = session.shell.open( :pty => true )

    loop do
      break unless shell.open?
      if IO.select([$stdin],nil,nil,0.01)
        data = $stdin.sysread(1)
        shell.send_data data
      end

      $stdout.print shell.stdout while shell.stdout?
      $stdout.flush
    end
  ensure
    stdin_buffer true
  end

end
