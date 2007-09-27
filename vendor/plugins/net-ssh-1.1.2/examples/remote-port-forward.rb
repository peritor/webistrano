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

class RemoteForwardListener
  def error( msg )
    raise "[#{self.class}] An error occurred: #{msg}"
  end

  def setup( remote_port )
    puts "[#{self.class}] forwarding enabled from remote port #{remote_port}"
  end

  def on_open( channel, c_addr, c_port, o_addr, o_port )
    puts "[#{self.class}] channel opened from remote server:"
    puts "   - connected address: #{c_addr}:#{c_port}"
    puts "   - originator address: #{o_addr}:#{o_port}"
  end

  def on_receive( channel, data )
    puts "data recevied from remote machine: #{data.inspect}"
    msg = "It worked! You just connected over a remote forwarded SSH " +
            "connection!\n\n" +
          "------\n" +
          data
    channel.send_data "HTTP/1.0 200 OK\r\n" +
                      "Content-Type: text/plain\r\n" +
                      "Content-Length: #{msg.length}\r\n" +
                      "\r\n" +
                      msg
  end

  def on_close( channel )
    puts "remote channel closed"
  end

  def on_eof( channel )
    puts "remote end of channel promised not to send any more data"
  end
end

Net::SSH.start( 'localhost' ) do |session|
  session.forward.remote( RemoteForwardListener.new, 12345 )

  trap("SIGINT") { session.close }

  begin
    session.loop { true }
  rescue Exception => e
    unless e.message =~ /connection closed by remote host/
      raise
    end
  end
end
