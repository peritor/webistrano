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

$:.unshift "#{File.dirname(__FILE__)}/../../lib"

require 'net/ssh/transport/version-negotiator'
require 'test/unit'

class TC_VersionNegotiator < Test::Unit::TestCase

  class MockLogger; def debug?; false; end; end

  class ScriptedSocket
    attr_reader :lines

    def initialize( *script )
      @lines = []
      @script = script
    end

    def readline
      @script.shift
    end

    def print( msg )
      @lines << msg
    end
  end

  def setup
    logger = MockLogger.new
    @negotiator = Net::SSH::Transport::VersionNegotiator.new( logger )
  end

  def test_negotiate_bad_version
    socket = ScriptedSocket.new( "SSH-1.5-Bogus/Thing\n" )
    assert_raise( Net::SSH::Exception ) do
      @negotiator.negotiate( socket, "SSH-2.0-My/Version" )
    end
  end

  def test_negotiate_compat_version
    socket = ScriptedSocket.new( "SSH-1.99-Bogus/Thing\n" )
    version = nil
    assert_nothing_raised do
      version = @negotiator.negotiate( socket, "SSH-2.0-My/Version" )
    end
    assert_equal "SSH-1.99-Bogus/Thing", version
    assert_equal [ "SSH-2.0-My/Version\r\n" ], socket.lines
  end

  def test_negotiate_good_version
    socket = ScriptedSocket.new( "SSH-2.0-Bogus/Thing\n" )
    version = nil
    assert_nothing_raised do
      version = @negotiator.negotiate( socket, "SSH-2.0-My/Version" )
    end
    assert_equal "SSH-2.0-Bogus/Thing", version
    assert_equal [ "SSH-2.0-My/Version\r\n" ], socket.lines
  end

  def test_header_lines
    socket = ScriptedSocket.new( "First Line", "Second Line", "SSH-2.0-Bogus/Thing\n" )
    version = nil
    assert_nothing_raised do
      version = @negotiator.negotiate( socket, "SSH-2.0-My/Version" )
    end
    assert_equal "SSH-2.0-Bogus/Thing", version
    assert_equal [ "SSH-2.0-My/Version\r\n" ], socket.lines
    assert_equal [ "First Line", "Second Line" ], @negotiator.header_lines
  end

end
