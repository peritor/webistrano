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
require 'net/sftp'

Net::SFTP.start( 'localhost',
  :registry_options => { :logs => { :levels => { "sftp.*" => :debug } } }
) do |sftp|
  closed = 0

  size = sftp.stat( "temp/out" ).size

  # setting this to a higher value typically causes problems...looks like it
  # might be a problem with OpenSSH, but I'm not sure.
  parts = 5

  chunk_size = size / parts
  chunks = []

  # Set up 'parts' read operations, each one pulling from a different segment
  # of the file. Each of these will be run in parallel.
  parts.times do |part|
    sftp.open( "temp/out" ) do |s,h|
      puts "----------------------------------------------"
      puts "got handle ##{part+1} (#{h.inspect})"
      sftp.read( h, chunk_size*part, chunk_size ) do |s,data|
        puts "----------------------------------------------"
        puts "got data ##{part+1} (#{data.length} bytes)"
        chunks[part] = data
        sftp.close_handle( h ) do
          closed += 1
          sftp.close_channel if closed == parts
        end
      end
    end
  end

  sftp.loop

  puts "----------------------------------------------"
  data = chunks.join
  puts "done! (#{data.length} bytes)"
end
