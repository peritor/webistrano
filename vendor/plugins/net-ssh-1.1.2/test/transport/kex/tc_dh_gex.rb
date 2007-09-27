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

$:.unshift "#{File.dirname(__FILE__)}/../../../lib"
$:.unshift File.dirname( __FILE__ )

require 'tc_dh' unless defined?(TC_KEX_DH)

require 'net/ssh/errors'
require 'net/ssh/transport/kex/dh-gex'
require 'net/ssh/util/buffer'
require 'test/unit'
require 'ostruct'

class TC_KEX_DH_GEX < TC_KEX_DH

  def setup
    @kex = Net::SSH::Transport::Kex::DiffieHellmanGroupExchangeSHA1.new(
      MockBNs.new, MockDigests.new )
    @kex.keys = MockKeys.new
    @kex.buffers = MockBuffers.new
    @kex.host_key_verifier = Net::SSH::NullHostKeyVerifier.new

    @init  = 32
    @reply = 33
    @session_id = "\0\0\0\1A\0\0\0\1B\0\0\0\1C\0\0\0\1D\0\0\0\1E\0\0\4\0\0\0\0\0\0\0\40\0[2][6][10][20][30]"

    @exchange_keys_script = [
      31,
      MockReaderBuffer.new( "\0\0\0\00210\0\0\0\00220" ),
      @reply,
      MockReaderBuffer.new( "\0\0\0\10key blob\0\0\0\0041001\0\0\0\27\0\0\0\10ssh-test\0\0\0\11signature" ),
      21,
      nil
    ]

    @exchange_keys_session_id =
      "\0\0\0\1A\0\0\0\1B\0\0\0\1C\0\0\0\1D\0\0\0\10key blob\0\0\4\0\0\0\4\0\0\0\40\0[10][20][1024][1001][9]"
  end

  def test_generate_key
    session = MockSession.new(
      31,
      MockReaderBuffer.new( "\0\0\0\00210\0\0\0\00220" )
    )

    dh = nil
    assert_nothing_raised do
      dh = @kex.generate_key( session, { :need_bytes=>200 } )
    end

    assert_equal 10, dh.p.to_i
    assert_equal 20, dh.g.to_i
    assert_equal 1600, dh.priv_key
  end


end
