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
require 'net/sftp/protocol/constants'
require 'net/sftp/protocol/01/impl'
require 'flexmock'
require 'net/ssh/util/buffer'

class TC_01_Impl < Test::Unit::TestCase

  class Buffers
    def reader( text )
      Net::SSH::Util::ReaderBuffer.new( text )
    end
  end

  def setup
    @sent_data = []
    @permissions = nil

    @driver = FlexMock.new
    @driver.mock_handle( :send_data ) { |*a| @sent_data << a }

    @assistant = FlexMock.new

    @attr_factory = FlexMock.new
    @attr_factory.mock_handle( :empty ) do
      o = FlexMock.new
      o.mock_handle( :permissions= ) { |p| @permissions = p }
      o
    end
    @attr_factory.mock_handle( :from_buffer ) do |b|
      b.read_long
    end

    @impl = impl_class.new( Buffers.new, @driver, @assistant, @attr_factory )
  end

  def impl_class
    Net::SFTP::Protocol::V_01::Impl
  end

  def self.operation( name, the_alias=name )
    class_eval <<-EOF, __FILE__, __LINE__+1
      def test_#{the_alias}
        @assistant.mock_handle( :#{name} ) { |*a| [ a[0], a[1..-1] ] }
        id = @impl.#{the_alias}( 14, :a, :b, :c )
        assert_equal 14, id
        assert_equal 1, @assistant.mock_count( :#{name} )
        assert_equal 1, @driver.mock_count( :send_data )
        assert_equal [
          [ Net::SFTP::Protocol::Constants::FXP_#{name.to_s.upcase},
          [ :a, :b, :c ]] ], @sent_data
      end
    EOF
  end

  operation :open, :open_raw
  operation :close
  operation :close, :close_handle
  operation :read
  operation :write
  operation :opendir
  operation :readdir
  operation :remove
  operation :stat, :stat_raw
  operation :lstat, :lstat_raw
  operation :fstat, :fstat_raw
  operation :setstat
  operation :fsetstat
  operation :mkdir
  operation :rmdir
  operation :realpath

  unless defined?( IO_FLAGS )
    IO_FLAGS = [ IO::RDONLY, IO::WRONLY, IO::RDWR, IO::APPEND ]
    OTHER_FLAGS = [ 0, IO::CREAT, IO::TRUNC, IO::EXCL ]
    MAP = { IO::RDONLY => 1, IO::WRONLY => 2, IO::RDWR => 3, IO::APPEND => 4,
            IO::CREAT => 8, IO::TRUNC => 0x10, IO::EXCL => 0x20 }

    IO_FLAGS.each do |flag|
      OTHER_FLAGS.each do |oflag|
        [ nil, 0400 ].each do |mode|
          define_method( "test_open_#{flag}_#{oflag}_#{mode||"nil"}" ) do
            @assistant.mock_handle( :open ) { |*a| [ a[0], a[1..-1] ] }
            args = [ 14, "a path", flag | oflag ]
            args << mode if mode
            assert_equal 14, @impl.open( *args )
            assert_equal 1, @assistant.mock_count( :open )
            assert_equal( ( mode || 0660 ), @permissions )
            sftp_flag = MAP[flag] | ( oflag == 0 ? 0 : MAP[oflag] )
            assert_equal Net::SFTP::Protocol::Constants::FXP_OPEN,
              @sent_data.first[0]
            assert_equal [ "a path", sftp_flag ], @sent_data.first[1][0,2]
          end
        end
      end
    end
  end

  def test_stat_flags
    @assistant.mock_handle( :stat ) { |*a| [ a[0], a[1..-1] ] }
    id = @impl.stat( 14, :a, :b )
    assert_equal 14, id
    assert_equal 1, @assistant.mock_count( :stat )
    assert_equal 1, @driver.mock_count( :send_data )
    assert_equal [
      [ Net::SFTP::Protocol::Constants::FXP_STAT, [ :a ]] ], @sent_data
  end

  def test_lstat_flags
    @assistant.mock_handle( :lstat ) { |*a| [ a[0], a[1..-1] ] }
    id = @impl.lstat( 14, :a, :b )
    assert_equal 14, id
    assert_equal 1, @assistant.mock_count( :lstat )
    assert_equal 1, @driver.mock_count( :send_data )
    assert_equal [
      [ Net::SFTP::Protocol::Constants::FXP_LSTAT, [ :a ]] ], @sent_data
  end

  def test_fstat_flags
    @assistant.mock_handle( :fstat ) { |*a| [ a[0], a[1..-1] ] }
    id = @impl.fstat( 14, :a, :b )
    assert_equal 14, id
    assert_equal 1, @assistant.mock_count( :fstat )
    assert_equal 1, @driver.mock_count( :send_data )
    assert_equal [
      [ Net::SFTP::Protocol::Constants::FXP_FSTAT, [ :a ]] ], @sent_data
  end

  def test_dispatch_bad
    assert_raise( Net::SFTP::Exception ) do
      @impl.dispatch( nil, -5, "blah" )
    end
  end

  def test_do_status_without_callback
    buffer = Net::SSH::Util::ReaderBuffer.new( "\0\0\0\1\0\0\0\2" )
    @impl.do_status( nil, buffer )
    assert_equal 0, buffer.position
  end

  def test_do_status_with_callback
    buffer = Net::SSH::Util::ReaderBuffer.new( "\0\0\0\1\0\0\0\2" )
    called = false
    @impl.on_status do |d,i,c,a,b|
      called = true
      assert_equal 1, i
      assert_equal 2, c
      assert_nil a
      assert_nil b
    end
    @impl.do_status nil, buffer
    assert called
  end

  def test_do_handle_without_callback
    buffer = Net::SSH::Util::ReaderBuffer.new( "\0\0\0\1\0\0\0\2ab" )
    @impl.do_handle( nil, buffer )
    assert_equal 0, buffer.position
  end

  def test_do_handle_with_callback
    buffer = Net::SSH::Util::ReaderBuffer.new( "\0\0\0\1\0\0\0\2ab" )
    called = false
    @impl.on_handle do |d,i,h|
      called = true
      assert_equal 1, i
      assert_equal "ab", h
    end
    @impl.do_handle nil, buffer
    assert called
  end

  def test_do_data_without_callback
    buffer = Net::SSH::Util::ReaderBuffer.new( "\0\0\0\1\0\0\0\7\0\0\0\3abc" )
    @impl.do_data( nil, buffer )
    assert_equal 0, buffer.position
  end

  def test_do_data_with_callback
    buffer = Net::SSH::Util::ReaderBuffer.new( "\0\0\0\1\0\0\0\7\0\0\0\3abc" )
    called = false
    @impl.on_data do |d,id,data|
      called = true
      assert_equal 1, id
      assert_equal "\0\0\0\3abc", data
    end
    @impl.do_data nil, buffer
    assert called
  end

  def test_do_name_without_callback
    buffer = Net::SSH::Util::ReaderBuffer.new( "\0\0\0\1\0\0\0\2" +
      "\0\0\0\1a\0\0\0\1b\0\0\0\0" )
    @impl.do_name( nil, buffer )
    assert_equal 0, buffer.position
  end

  def test_do_name_with_callback
    buffer = Net::SSH::Util::ReaderBuffer.new( "\0\0\0\1\0\0\0\2" +
      "\0\0\0\1a\0\0\0\1b\0\0\0\0" +
      "\0\0\0\1c\0\0\0\1d\0\0\0\0" )
    called = false
    @impl.on_name do |d,i,names|
      called = true
      assert_equal 1, i
      assert_equal 2, names.length
      assert_equal "a", names.first.filename
      assert_equal "b", names.first.longname
      assert_equal 0, names.first.attributes
      assert_equal "c", names.last.filename
      assert_equal "d", names.last.longname
      assert_equal 0, names.last.attributes
    end
    @impl.do_name nil, buffer
    assert called
  end

  def test_do_attrs_without_callback
    buffer = Net::SSH::Util::ReaderBuffer.new( "\0\0\0\1\0\0\0\0" )
    @impl.do_attrs( nil, buffer )
    assert_equal 0, buffer.position
  end

  def test_do_attrs_with_callback
    buffer = Net::SSH::Util::ReaderBuffer.new( "\0\0\0\1\0\0\0\0" )
    called = false
    @impl.on_attrs do |d,i,a|
      called = true
      assert_equal 1, i
      assert_equal 0, a
    end
    @impl.do_attrs nil, buffer
    assert called
  end

  def test_dispatch_status
    buffer = Net::SSH::Util::ReaderBuffer.new( "" )
    called = false
    @impl.on_status { called = true }
    @impl.dispatch( nil, Net::SFTP::Protocol::Constants::FXP_STATUS, buffer )
    assert called
  end

  def test_dispatch_handle
    buffer = Net::SSH::Util::ReaderBuffer.new( "" )
    called = false
    @impl.on_handle { called = true }
    @impl.dispatch( nil, Net::SFTP::Protocol::Constants::FXP_HANDLE, buffer )
    assert called
  end

  def test_dispatch_data
    buffer = Net::SSH::Util::ReaderBuffer.new( "" )
    called = false
    @impl.on_data { called = true }
    @impl.dispatch( nil, Net::SFTP::Protocol::Constants::FXP_DATA, buffer )
    assert called
  end

  def test_dispatch_name
    buffer = Net::SSH::Util::ReaderBuffer.new( "\0\0\0\0\0\0\0\0" )
    called = false
    @impl.on_name { called = true }
    @impl.dispatch( nil, Net::SFTP::Protocol::Constants::FXP_NAME, buffer )
    assert called
  end

  def test_dispatch_attrs
    buffer = Net::SSH::Util::ReaderBuffer.new( "" )
    called = false
    @impl.on_attrs { called = true }
    @impl.dispatch( nil, Net::SFTP::Protocol::Constants::FXP_ATTRS, buffer )
    assert called
  end

end
