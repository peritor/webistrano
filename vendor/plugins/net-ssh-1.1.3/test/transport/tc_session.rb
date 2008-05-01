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

require 'net/ssh/transport/constants'
require 'net/ssh/transport/session'
require 'net/ssh/util/buffer'
require 'test/unit'
require 'ostruct'

class TC_Session < Test::Unit::TestCase
  include Net::SSH::Transport::Constants

  class Logger
    attr_reader :msgs
    def initialize
      @msgs = []
    end
    def debug?; true; end
    def debug(msg)
      @msgs << "[D] #{msg}"
    end
    def info?; true; end
    def info(msg)
      @msgs << "[I] #{msg}"
    end
    def warn?; true; end
    def warn(msg)
      @msgs << "[W] #{msg}"
    end
  end

  class VersionNegotiator
    def negotiate( socket, version ); "A"; end
  end

  class AlgorithmNegotiator
    def negotiate( session, options )
      OpenStruct.new(
        :server_packet => "A",
        :client_packet => "B",
        :kex => "C",
        :host_key => "D",
        :encryption_c2s => "E",
        :encryption_s2c => "E",
        :mac_c2s => "F",
        :mac_s2c => "F",
        :compression_c2s => "G",
        :compression_s2c => "G",
        :language_c2s => "",
        :language_s2c => ""
      )
    end
  end

  class ScriptedSocket
    attr_reader :replies
    attr_accessor :open_delay

    def initialize( script )
      @replies = []
      @script = script
      @open_delay = 0
    end

    def open( host, port )
      @replies << "#{host}:#{port}"
      sleep @open_delay
      self
    end

    def write( msg )
      @replies << msg
    end

    def read
      @script.shift
    end
  end

  class PacketHandler
    attr_writer :socket
    def on_new_algos( &block )
      @on_new_algos = block
    end
    def set_algorithms( *args )
      @on_new_algos.call(*args) if @on_new_algos
    end
  end

  class PacketSender < PacketHandler
    def send( msg )
      @socket.write msg
    end
  end

  class PacketReceiver < PacketHandler
    def get
      @socket.read
    end
  end

  class Ciphers
    def get( *args )
      args.first
    end
    def get_lengths( name )
      [ 24, 8 ]
    end
  end

  class HMACs
    def get( *args )
      args.first
    end
    def get_key_length( name )
      24
    end
  end

  class Compressor
    def initialize( *args )
    end
  end

  class SSHAble; def to_ssh; ""; end; end

  class Digester
    def digest( text )
      text
    end
  end

  class Kex
    def exchange_keys( session, info )
      {
        :shared_secret => SSHAble.new,
        :session_id => "",
        :server_key => "",
        :hashing_algorithm => Digester.new
      }
    end
  end

  def self.method_added( name )
    super

  end

  def reader(text)
    Net::SSH::Util::ReaderBuffer.new( text )
  end

  def setup
    @script = []
    @logger = Logger.new
    @socket = ScriptedSocket.new( @script )
    @sender = PacketSender.new
    @getter = PacketReceiver.new
  end

  def do_setup( host, opts={} )
    @session = Net::SSH::Transport::Session.new( host, opts ) do |s|
      s.logger = @logger
      s.default_port = 22
      s.version_negotiator = VersionNegotiator.new
      s.algorithm_negotiator = AlgorithmNegotiator.new
      s.socket_factory = @socket
      s.packet_sender = @sender
      s.packet_receiver = @getter
      s.ciphers = Ciphers.new
      s.hmacs = HMACs.new
      s.kexs = { "C" => Kex.new }
      s.compressors = { "G" => Compressor }
      s.decompressors = { "G" => Compressor }
    end
  end

  def test_bad_option
    assert_raise( ArgumentError ) do
      do_setup( "the-host", :bogus => "thing" )
    end
  end

  def test_open
    @sender.on_new_algos do |a,b,c|
      assert_equal "E", a
      assert_equal "F", b
      assert_instance_of Compressor, c
    end

    @getter.on_new_algos do |a,b,c|
      assert_equal "E", a
      assert_equal "F", b
      assert_instance_of Compressor, c
    end

    do_setup "the.host.com"

    assert_equal [ "the.host.com:22" ], @socket.replies
  end

  def test_send_message
    do_setup "the.host.com"
    @session.send_message "sending"
    assert_equal [ "the.host.com:22", "sending" ], @socket.replies
  end

  def test_wait_for_message
    @script << reader( "\xFFhello" )
    do_setup "the.host.com"
    type, buffer = @session.wait_for_message
    assert_equal 255, type
    assert_equal "hello", buffer.remainder_as_buffer.content
  end

  def test_wait_for_disconnect
    @script << reader( "#{DISCONNECT.chr}\0\0\0\1\0\0\0\1A\0\0\0\1B" )
    do_setup "the.host.com"
    assert_raise( Net::SSH::Transport::Disconnect ) do
      @session.wait_for_message
    end
  end

  def test_wait_for_ignore
    @script << reader( "#{IGNORE.chr}\0\0\0\1A" )
    @script << reader( "\xFFhello" )
    do_setup "the.host.com"
    type, buffer = @session.wait_for_message

    assert_equal 255, type
    assert_equal "hello", buffer.remainder_as_buffer.content

    assert @logger.msgs.include?("[I] received IGNORE message (\"A\")")
  end

  def test_wait_for_debug_quiet
    @script << reader( "#{DEBUG.chr}\0\0\0\0\1A\0\0\0\1B" )
    @script << reader( "\xFFhello" )
    do_setup "the.host.com"
    type, buffer = @session.wait_for_message

    assert_equal 255, type
    assert_equal "hello", buffer.remainder_as_buffer.content

    assert @logger.msgs.include?("[D] A (B)")
  end

  def test_wait_for_debug_verbose
    @script << reader( "#{DEBUG.chr}\1\0\0\0\1A\0\0\0\1B" )
    @script << reader( "\xFFhello" )
    do_setup "the.host.com"
    type, buffer = @session.wait_for_message

    assert_equal 255, type
    assert_equal "hello", buffer.remainder_as_buffer.content

    assert @logger.msgs.include?("[W] A (B)")
  end

  def test_wait_for_kexinit
    @script << reader( "#{KEXINIT.chr}\1\0\0\0\1A\0\0\0\1B" )
    @script << reader( "\xFFhello" )
    do_setup "the.host.com"
    type, buffer = @session.wait_for_message

    assert_equal 255, type
    assert_equal "hello", buffer.remainder_as_buffer.content

    assert @logger.msgs.include?("[I] re-key requested")
  end

  def test_timeout_expired
    @socket.open_delay = 2
    assert_raise(Timeout::Error) { do_setup( "the.host.com", :timeout => 1 ) }
  end

  def test_timeout_not_expired
    @socket.open_delay = 1
    assert_nothing_raised { do_setup( "the.host.com", :timeout => 2 ) }
  end
end
