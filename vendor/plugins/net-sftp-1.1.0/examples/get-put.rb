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
  File.open( "test.data", "w" ) { |f| f.write "012345789"*10000 }
  
  puts "putting local file to remote location..."
  sftp.put_file "test.data", "temp/blah.data"

  puts "getting remote file to local location..."
  sftp.get_file "temp/blah.data", "new.data"

  sftp.remove "temp/blah.data"

  if !File.exist? "new.data"
    warn "----\n" +
         "something went wrong---'new.data' was apparently not created..." +
         "----\n"
  else
    File.delete "new.data"
  end

  File.delete "test.data"

  puts "----------------------------------------------"
  puts "done!"
end
