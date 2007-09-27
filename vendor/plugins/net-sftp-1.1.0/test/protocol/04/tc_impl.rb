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
$:.unshift File.join( File.dirname( __FILE__ ), ".." )

require 'net/sftp/protocol/04/impl'
require '03/tc_impl'

class TC_04_Impl < TC_03_Impl

  def impl_class
    Net::SFTP::Protocol::V_04::Impl
  end

  def test_stat_flags
    @assistant.mock_handle( :stat ) { |*a| [ a[0], a[1..-1] ] }
    id = @impl.stat( 14, :a, :b )
    assert_equal 14, id
    assert_equal 1, @assistant.mock_count( :stat )
    assert_equal 1, @driver.mock_count( :send_data )
    assert_equal [
      [ Net::SFTP::Protocol::Constants::FXP_STAT, [ :a, :b ]] ], @sent_data
  end

  def test_lstat_flags
    @assistant.mock_handle( :lstat ) { |*a| [ a[0], a[1..-1] ] }
    id = @impl.lstat( 14, :a, :b )
    assert_equal 14, id
    assert_equal 1, @assistant.mock_count( :lstat )
    assert_equal 1, @driver.mock_count( :send_data )
    assert_equal [
      [ Net::SFTP::Protocol::Constants::FXP_LSTAT, [ :a, :b ]] ], @sent_data
  end

  def test_fstat_flags
    @assistant.mock_handle( :fstat ) { |*a| [ a[0], a[1..-1] ] }
    id = @impl.fstat( 14, :a, :b )
    assert_equal 14, id
    assert_equal 1, @assistant.mock_count( :fstat )
    assert_equal 1, @driver.mock_count( :send_data )
    assert_equal [
      [ Net::SFTP::Protocol::Constants::FXP_FSTAT, [ :a, :b ]] ], @sent_data
  end

  def test_rename_flags
    @assistant.mock_handle( :rename ) { |*a| [ a[0], a[1..-1] ] }
    id = @impl.rename( 14, :a, :b, :c )
    assert_equal 14, id
    assert_equal 1, @assistant.mock_count( :rename )
    assert_equal 1, @driver.mock_count( :send_data )
    assert_equal [
      [ Net::SFTP::Protocol::Constants::FXP_RENAME, [ :a, :b, :c ]] ],
      @sent_data
  end

  # overrides the v1 implementation of the test
  def test_do_name_with_callback
    buffer = Net::SSH::Util::ReaderBuffer.new( "\0\0\0\1\0\0\0\2" +
      "\0\0\0\1a\0\0\0\0" +
      "\0\0\0\1c\0\0\0\0" )
    called = false
    @impl.on_name do |d,i,names|
      called = true
      assert_equal 1, i
      assert_equal 2, names.length
      assert_equal "a", names.first.filename
      assert_nil names.first.longname
      assert_equal 0, names.first.attributes
      assert_equal "c", names.last.filename
      assert_nil names.last.longname
      assert_equal 0, names.last.attributes
    end
    @impl.do_name nil, buffer
    assert called
  end

end
