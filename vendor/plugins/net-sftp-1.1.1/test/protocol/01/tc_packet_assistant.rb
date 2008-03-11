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

$:.unshift "../../../lib"

require 'test/unit'
require 'net/sftp/protocol/01/packet-assistant'
require 'flexmock'
require 'net/ssh/util/buffer'

class TC_01_PacketAssistant < Test::Unit::TestCase

  class Buffers
    def writer
      Net::SSH::Util::WriterBuffer.new
    end
  end

  def setup
    @driver = FlexMock.new
    @driver.mock_handle( :next_request_id ) { 14 }
    @packets = packet_assistant_class.new( Buffers.new, @driver )
  end

  def packet_assistant_class
    Net::SFTP::Protocol::V_01::PacketAssistant
  end

  def self.packet( name, args, expect )
    define_method( "test_#{name}" ) do
      id, packet = @packets.__send__( name, *[ nil, *args ] )
      assert_equal 14, id
      assert_equal "\0\0\0\16" + expect, packet
    end
  end

  packet :open, [ "a path", 1, "attrs" ], "\0\0\0\6a path\0\0\0\1attrs"

  packet :close, [ "handle" ], "\0\0\0\6handle"

  packet :read, [ "handle", 0, 16 ], "\0\0\0\6handle\0\0\0\0\0\0\0\0\0\0\0\20"

  packet :write, [ "handle", 0, "data" ],
    "\0\0\0\6handle\0\0\0\0\0\0\0\0\0\0\0\4data"

  packet :opendir, [ "a path" ], "\0\0\0\6a path"

  packet :readdir, [ "handle" ], "\0\0\0\6handle"

  packet :remove, [ "a path" ], "\0\0\0\6a path"

  packet :stat, [ "a path" ], "\0\0\0\6a path"

  packet :lstat, [ "a path" ], "\0\0\0\6a path"

  packet :fstat, [ "handle" ], "\0\0\0\6handle"

  packet :setstat, [ "a path", "attrs" ], "\0\0\0\6a pathattrs"

  packet :fsetstat, [ "handle", "attrs" ], "\0\0\0\6handleattrs"

  packet :mkdir, [ "a path", "attrs" ], "\0\0\0\6a pathattrs"

  packet :rmdir, [ "a path" ], "\0\0\0\6a path"

  packet :realpath, [ "a path" ], "\0\0\0\6a path"

end
