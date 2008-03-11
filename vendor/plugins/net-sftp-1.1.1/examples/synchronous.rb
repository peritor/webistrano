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
  puts "----------------------------------------------"
  puts "getting handle..."
  handle = sftp.open_handle( "temp/out" )
  puts "got handle: #{handle.inspect}"
  puts "reading..."
  data = sftp.read( handle,
            :chunk_size => 4*1024,
            :progress_callback => proc { |data| puts "  [#{data.length}]" } )
  puts "got data: #{data.length} bytes"
  sftp.close_handle( handle )

  puts "----------------------------------------------"
  puts "getting handle..."
  sftp.open_handle( "temp/out" ) do |handle|
    puts "got handle: #{handle.inspect}"
    puts "reading..."
    data = sftp.read( handle )
    puts "got data: #{data.length} bytes"
  end

  puts "----------------------------------------------"
  puts "opening handle for writing..."
  sftp.open_handle( "temp/blah", "w" ) do |handle|
    puts "got handle: #{handle.inspect}"
    data = "1234567890" * 100
    puts "writing #{data.length} bytes..."
    p sftp.write( handle, data ).code
  end

  puts "----------------------------------------------"
  puts "opening handle for writing..."
  handle = sftp.open( "temp/blah", IO::WRONLY | IO::CREAT )
  puts "got handle: #{handle.inspect}"
  data = "1234567890" * 100000
  puts "writing #{data.length} bytes..."
  p sftp.write( handle, data ).code
  sftp.close_handle( handle )

  puts "----------------------------------------------"
  puts "opening directory handle..."
  handle = sftp.opendir( "/usr/lib" )
  puts "got handle: #{handle.inspect}"
  puts "reading directory..."
  items = sftp.readdir( handle )
  puts "got #{items.length} entries"
  sftp.close_handle( handle )

  puts "----------------------------------------------"
  puts "removing file..."
  p sftp.remove( "temp/blah" ).code

  puts "----------------------------------------------"
  puts "getting attributes (stat)..."
  p sftp.stat( "temp/out" )

  puts "----------------------------------------------"
  puts "getting attributes (lstat)..."
  p sftp.lstat( "temp/out" )

  puts "----------------------------------------------"
  puts "getting handle..."
  handle = sftp.open( "temp/out" )
  puts "getting attributes (fstat)..."
  p sftp.fstat( handle )
  sftp.close_handle( handle )

  puts "----------------------------------------------"
  puts "setting attributes (setstat)..."
  p sftp.setstat( "temp/out", :permissions => 0777 )
  puts "getting attributes (stat)..."
  p sftp.stat( "temp/out" )

  puts "----------------------------------------------"
  puts "getting handle..."
  handle = sftp.open( "temp/out" )
  puts "setting attributes (fsetstat)..."
  p sftp.fsetstat( handle, :permissions => 0660 )
  sftp.close_handle( handle )
  puts "getting attributes (stat)..."
  p sftp.stat( "temp/out" )

  puts "----------------------------------------------"
  puts "mkdir..."
  p sftp.mkdir( "temp/test_dir", :permissions => 0500 )
  puts "getting attributes (stat)..."
  p sftp.stat( "temp/test_dir" )

  puts "----------------------------------------------"
  puts "rmdir..."
  p sftp.rmdir( "temp/test_dir" )

  puts "----------------------------------------------"
  puts "realpath..."
  p sftp.realpath( "." )

  # 'rename' is only available from protocol version 2+.
  if sftp.support?( :rename )
    puts "----------------------------------------------"
    puts "rename..."
    p sftp.rename( "temp/out", "temp/out2" )
    puts "getting realpath..."
    p sftp.realpath( "temp/out2" )
    puts "restoring name..."
    p sftp.rename( "temp/out2", "temp/out" )
  end

  puts "----------------------------------------------"
  puts "done!"
end
