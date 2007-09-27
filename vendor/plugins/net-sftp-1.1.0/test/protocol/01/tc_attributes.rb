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
require 'net/sftp/protocol/01/attributes'

require 'net/ssh'
require 'net/ssh/util/buffer'

class TC_01_Attributes < Test::Unit::TestCase

  class Buffers
    def writer
      Net::SSH::Util::WriterBuffer.new
    end
    def reader( text )
      Net::SSH::Util::ReaderBuffer.new( text )
    end
  end

  def setup
    @factory = Net::SFTP::Protocol::V_01::Attributes.init( Buffers.new )
  end

  def test_empty
    empty = @factory.empty
    assert_nil empty.size
    assert_nil empty.uid
    assert_nil empty.gid
    assert_nil empty.permissions
    assert_nil empty.atime
    assert_nil empty.mtime
    assert_nil empty.extended
    assert_equal "\0\0\0\0", empty.to_s
  end

  def test_from_buffer_empty
    buffer = @factory.buffers.reader( "\0\0\0\0" )
    attrs = @factory.from_buffer( buffer )
    assert_nil attrs.size
    assert_nil attrs.uid
    assert_nil attrs.gid
    assert_nil attrs.permissions
    assert_nil attrs.atime
    assert_nil attrs.mtime
    assert_nil attrs.extended
    assert_equal "\0\0\0\0", attrs.to_s
  end

  ATTRIBUTES = 
    [ [ 1, "\1\2\3\4\5\6\7\10", :size, 0x0102030405060708 ],
      [ 2, "\11\12\13\14\15\16\17\20", :uid, 0x090A0B0C ],
      [ 2, "\11\12\13\14\15\16\17\20", :gid, 0x0D0E0F10 ],
      [ 4, "\21\22\23\24", :permissions, 0x11121314 ],
      [ 8, "\25\26\27\30\31\32\33\34", :atime, 0x15161718 ],
      [ 8, "\25\26\27\30\31\32\33\34", :mtime, 0x191A1B1C ],
      [ 0x80000000,
        "\0\0\0\4" +
        "\0\0\0\01a\0\0\0\01b" +
        "\0\0\0\01c\0\0\0\01d" +
        "\0\0\0\01e\0\0\0\01f" +
        "\0\0\0\01g\0\0\0\01h",
        :extended,
        { "a" => "b", "c" => "d", "e" => "f", "g" => "h" } ] ]

  # find all possible combinations of the elements of ATTRIBUTES
  # (i.e., 'n' choose k, for k in [1..ATTRIBUTES.length]).
  def self.choose( from, k )
    result = []
    ( from.length - k + 1 ).times do |i|
      if i+1 < from.length && k > 1
        choose( from[i+1..-1], k-1 ).each do |chosen|
          result << [ from[i], *chosen ]
        end
      else
        result << [ from[i] ]
      end
    end
    result
  end

  method_id = 0
  ATTRIBUTES.length.times do |k|
    choose( ATTRIBUTES, k+1 ).each do |attrs|
      define_method( "test_attributes_%03d" % method_id ) do
        flags = 0
        buffer = ""
        attrs.each do |a|
          if ( flags & a[0] ) == 0
            flags |= a[0]
            buffer += a[1]
          end
        end
        buffer = [ flags, buffer ].pack( "NA*" )
        input = @factory.buffers.reader( buffer )
        obj = @factory.from_buffer( input )
        attrs.each { |a| assert_equal a[3], obj.__send__( a[2] ) }
        assert_equal buffer, obj.to_s
      end
      method_id += 1
    end
  end

  require 'etc'
  [
    [ { :size => 1000 }, :size, 1000, :uid ],
    [ { :uid => 1000 }, :uid, 1000 ],
    [ { :gid => 1000 }, :gid, 1000 ],
    [ { :permissions => 0600 }, :permissions, 0600 ],
    [ { :atime => 123456 }, :atime, 123456 ],
    [ { :mtime => 789012 }, :mtime, 789012 ],
    [ { :extended => { "foo" => "bar" } }, :extended, { "foo" => "bar" } ],
    [ { :owner => ENV['USER'] }, :uid, Etc.getpwnam(ENV['USER']).uid ],
    [ { :group => 'wheel' }, :gid, Etc.getgrnam('wheel').gid ]
  ].each do |fixture|
    define_method( "test_from_hash_#{fixture[1]}" ) do
      attrs = @factory.from_hash( fixture[0] )
      assert_equal fixture[2], attrs.__send__( fixture[1] )
      assert_nil attrs.__send__( fixture[3] || :size )
    end
  end

end
