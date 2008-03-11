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

$:.unshift "../../lib"

require 'test/unit'
require 'net/sftp/protocol/driver'
require 'net/ssh/util/buffer'
require 'flexmock'

class TC_Protocol_Driver < Test::Unit::TestCase

  class Buffers
    def writer
      Net::SSH::Util::WriterBuffer.new
    end
    def reader( text )
      Net::SSH::Util::ReaderBuffer.new( text )
    end
  end

  def reader( text )
    Net::SSH::Util::ReaderBuffer.new( text )
  end

  def force_state( state )
    @driver.instance_eval { @state = state }
  end

  def setup
    @channel = FlexMock.new
    @channel.mock_handle( :close )
    @channel.mock_handle( :subsystem )
    @channel.mock_handle( :on_success )
    @channel.mock_handle( :on_data )
    @channel.mock_handle( :send_data )

    @connection = FlexMock.new
    @connection.mock_handle( :open_channel ) { @channel }

    @log = FlexMock.new
    @log.mock_handle( :debug? )
    @log.mock_handle( :debug )
    @log.mock_handle( :info? )
    @log.mock_handle( :info )

    @dispatchers = FlexMock.new

    @dispatcher = FlexMock.new

    @dispatchers.mock_handle( :[] ) do |v,e|
      @version = v
      @extensions = e
      @dispatcher
    end

    @driver = Net::SFTP::Protocol::Driver.new( @connection, Buffers.new, 5,
      @dispatchers, @log )
  end

  def test_initial_state
    assert_equal :unconfirmed, @driver.state
  end

  def test_close
    @driver.close
    assert_equal 1, @channel.mock_count( :close )
    assert_equal :closed, @driver.state
  end

  def test_next_request_id
    assert_equal 0, @driver.next_request_id
    assert_equal 1, @driver.next_request_id
    assert_equal 2, @driver.next_request_id
  end

  def test_do_confirm_bad_state
    force_state :bogus
    assert_raise( Net::SFTP::Bug ) { @driver.do_confirm @channel }
  end

  def test_do_confirm
    force_state :unconfirmed
    @channel.mock_handle( :subsystem ) { |a| assert_equal "sftp", a }
    @driver.do_confirm @channel
    assert_equal 1, @channel.mock_count( :subsystem )
    assert_equal 1, @channel.mock_count( :on_success )
    assert_equal 1, @channel.mock_count( :on_data )
    assert_equal :init, @driver.state
  end

  def test_do_success_bad_state
    force_state :bogus
    assert_raise( Net::SFTP::Bug ) { @driver.do_success @channel }
  end

  def test_do_success
    force_state :init
    packet = nil
    @channel.mock_handle( :send_data ) { |p| packet = p }
    @driver.do_success @channel
    assert_equal 1, @channel.mock_count( :send_data )
    assert_equal "\0\0\0\5\1\0\0\0\5", packet.to_s
  end

  def test_version_bad_state
    force_state :bogus
    assert_raise( Net::SFTP::Bug ) { @driver.do_version nil }
  end

  def test_version_server_higher
    force_state :version
    @driver.do_version reader( "\0\0\0\7" )
    assert_equal 5, @version
    assert_equal Hash.new, @extensions
    assert_equal :open, @driver.state
  end

  def test_version_server_lower
    force_state :version
    @driver.do_version reader( "\0\0\0\3" )
    assert_equal 3, @version
    assert_equal Hash.new, @extensions
    assert_equal :open, @driver.state
  end

  def test_version_extensions
    force_state :version
    @driver.do_version reader( "\0\0\0\3\0\0\0\1a\0\0\0\1b\0\0\0\1c\0\0\0\1d" )
    assert_equal( {"a"=>"b","c"=>"d"}, @extensions )
  end

  def test_version_with_on_open
    force_state :version
    called = false
    @driver.on_open { called = true }
    @driver.do_version reader( "\0\0\0\3" )
    assert called
  end

  def test_do_data_version
    force_state :version
    @driver.do_data( nil, "\0\0\0\5\2\0\0\0\3" )
    assert_equal 1, @dispatchers.mock_count( :[] )
  end

  def test_do_dispatch
    # define the dispatcher
    force_state :version
    @driver.do_version reader( "\0\0\0\3" )

    channel = type = content = 0
    @dispatcher.mock_handle( :dispatch ) { |c,t,n|
      channel, type, content = c,t,n }
    @driver.do_data( nil, "\0\0\0\5\7\0\0\0\0" )
    assert_equal 1, @dispatcher.mock_count(:dispatch)
    assert_nil channel
    assert_equal 7, type
    assert_equal "\0\0\0\0", content.to_s
  end

  def test_do_dispatch_multipass
    # define the dispatcher
    force_state :version
    @driver.do_version reader( "\0\0\0\3" )

    channel = type = content = 0
    @dispatcher.mock_handle( :dispatch ) { |c,t,n|
      channel, type, content = c,t,n }
    @driver.do_data( nil, "\0\0\0\5\7\0\0" )

    assert_equal 0, @dispatcher.mock_count(:dispatch)
    assert_equal 0, channel
    assert_equal 0, type
    assert_equal 0, content

    @driver.do_data( nil, "\0\0" )

    assert_equal 1, @dispatcher.mock_count(:dispatch)
    assert_nil channel
    assert_equal 7, type
    assert_equal "\0\0\0\0", content.to_s
  end

  def test_method_missing_found
    force_state :version
    @driver.do_version reader( "\0\0\0\3" )

    def @dispatcher.respond_to?(sym)
      super || sym == :foo
    end

    @dispatcher.mock_handle( :foo )
    assert @driver.respond_to?( :foo )

    @driver.foo

    assert_equal 1, @dispatcher.mock_count( :foo )
  end

  def test_method_missing_not_found
    assert !@driver.respond_to?( :foo )
    assert_raise( NoMethodError ) { @driver.foo }
  end

end
