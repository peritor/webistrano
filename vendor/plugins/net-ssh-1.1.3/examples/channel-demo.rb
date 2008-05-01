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

  # Note: two things here,
  #
  # 1) open_channel does not immediately invoke the associated block. It only
  #    calls the block after the server has confirmed that the channel is valid.
  # 2) channel.exec does not block--it just sends the request to the server and
  #    returns.
  #
  # For these two reasons, you MUST call session.loop, so that packets get
  # processed and dispatched to the appropriate channel for handling.

  def exec( command )
    lambda do |channel|
      channel.exec command
      channel.on_data do |ch,data|
        ch[:data] ||= ""
        ch[:data] << data
      end
      channel.on_extended_data do |ch,type,data|
        ch[:extended_data] ||= []
        ch[:extended_data][type] ||= ""
        ch[:extended_data][type] << data
      end
    end
  end

  channels = []
  channels.push session.open_channel( &exec( "echo $HOME" ) )
  channels.push session.open_channel( &exec( "ls -la /" ) )
  channels.push session.open_channel( &exec( "bogus-command" ) )

  # Process packets from the server and route them to the appropriate channel
  # for handling.

  session.loop

  # Display the results.

  channels.each do |c|
    puts "----------------------------------"
    if c.valid?
      puts c[:data]
      if c[:extended_data] && c[:extended_data][1]
        puts "-- stderr: --"
        puts c[:extended_data][1]
      end
    else
      puts "channel was not opened: #{c.reason} (#{c.reason_code})"
    end
  end
end
