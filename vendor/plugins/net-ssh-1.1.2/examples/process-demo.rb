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

  # ===========================================================================

  session.process.open( "bc" ) do |bc|
    dialog = [ "5+5", "7*12", "sqrt(2.000000)" ]

    bc.on_success do |p|
      puts "process started successfully. starting interactive session."
      puts "requesting result of #{dialog.first}"
      p.puts dialog.shift
    end

    bc.on_failure do |p, status|
      puts "process failed to start (#{status})"
    end

    bc.on_stdout do |p,data|
      puts "--> #{data}"
      unless dialog.empty?
        puts "requesting result of #{dialog.first}"
        p.puts dialog.shift
      else
        p.close_input
      end
    end

    bc.on_stderr do |p,data|
      puts "got stuff from stderr: #{data}"
    end

    bc.on_exit do |p, status|
      puts "process finished with exit status: #{status}"
    end
  end

  puts "done!"

  # ===========================================================================

  puts "now, trying 'bc' with popen3..."

  input, output, error = session.process.popen3( "bc" )
  input.puts "5+5"
  puts "5+5=#{output.read}"
  input.puts "10*2"
  puts "10*2=#{output.read}"
  input.puts "quit"

  # ===========================================================================

  puts "trying 'cat' with popen3"
  session.process.popen3( "cat" ) do |input,output,error|
    input.puts "hello"
    puts output.read
    input.puts "world"
    puts output.read
  end

  puts "done!"

end
