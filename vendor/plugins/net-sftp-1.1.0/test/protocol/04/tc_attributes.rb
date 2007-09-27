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
require 'net/sftp/protocol/04/attributes'

require 'net/ssh'
require 'net/ssh/util/buffer'

class TC_04_Attributes < Test::Unit::TestCase

  class Buffers
    def writer
      Net::SSH::Util::WriterBuffer.new
    end
    def reader( text )
      Net::SSH::Util::ReaderBuffer.new( text )
    end
  end

  def setup
    @factory = Net::SFTP::Protocol::V_04::Attributes.init( Buffers.new )
  end

  def test_empty
    empty = @factory.empty
    assert_equal 1, empty.type
    assert_nil empty.size
    assert_nil empty.owner
    assert_nil empty.group
    assert_nil empty.permissions
    assert_nil empty.atime
    assert_nil empty.atime_nseconds
    assert_nil empty.ctime
    assert_nil empty.ctime_nseconds
    assert_nil empty.mtime
    assert_nil empty.mtime_nseconds
    assert_nil empty.acl
    assert_nil empty.extended
    assert_equal "\0\0\0\0\1", empty.to_s
  end

  def test_from_buffer_empty
    buffer = @factory.buffers.reader( "\0\0\0\0\2" )
    attrs = @factory.from_buffer( buffer )
    assert_equal 2, attrs.type
    assert_nil attrs.size
    assert_nil attrs.owner
    assert_nil attrs.group
    assert_nil attrs.permissions
    assert_nil attrs.atime
    assert_nil attrs.atime_nseconds
    assert_nil attrs.ctime
    assert_nil attrs.ctime_nseconds
    assert_nil attrs.mtime
    assert_nil attrs.mtime_nseconds
    assert_nil attrs.acl
    assert_nil attrs.extended
    assert_equal "\0\0\0\0\2", attrs.to_s
  end

  ACL = Net::SFTP::Protocol::V_04::Attributes::ACL
  ATTRIBUTES = 
    [ [ 0x00000001, "\1\2\3\4\5\6\7\10", :size, 0x0102030405060708 ],
      [ 0x00000080, "\0\0\0\1a\0\0\0\1b", :owner, "a" ],
      [ 0x00000080, "\0\0\0\1a\0\0\0\1b", :group, "b" ],
      [ 0x00000004, "\21\22\23\24", :permissions, 0x11121314 ],
      [ 0x00000138,
        "\1\1\1\1\1\1\1\1\0\1\2\3" +
        "\2\2\2\2\2\2\2\2\4\5\6\7" +
        "\3\3\3\3\3\3\3\3\2\4\6\10", :atime_nseconds, 0x00010203 ],
      [ 0x00000008, "\1\2\3\4\1\2\3\4", :atime, 0x0102030401020304 ],
      [ 0x00000010, "\4\3\4\3\4\3\4\3", :ctime, 0x0403040304030403 ],
      [ 0x00000020, "\4\3\2\1\4\3\2\1", :mtime, 0x0403020104030201 ],
      [ 0x00000040, "\0\0\0\46\0\0\0\2\0\0\0\1\0\0\0\2\0\0\0\3\0\0\0\1a" +
        "\0\0\0\4\0\0\0\5\0\0\0\6\0\0\0\1b", :acl,
        [ ACL.new( 1, 2, 3, "a" ), ACL.new( 4, 5, 6, "b" ) ] ],
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
      vars = attrs.map { |a| a[2] }.join( "_" )
      define_method( "test_attributes_#{vars}_%03d" % method_id ) do
        flags = 0
        buffer = "\1"
        attrs.each do |a|
          if ( flags & a[0] ) == 0
            flags |= a[0]
            buffer += a[1]
          end
        end
        buffer = [ flags, buffer ].pack( "NA*" )
        input = @factory.buffers.reader( buffer )
        obj = @factory.from_buffer( input )
        assert_equal 1, obj.type, vars
        flags = 0
        attrs.each do |a|
          if ( flags & a[0] ) == 0
            assert_equal a[3], obj.__send__( a[2] ), a[2]
            flags |= a[0]
          end
        end
        assert_equal buffer, obj.to_s, vars
      end
      method_id += 1
    end
  end

  require 'etc'
  [
    [ { :type => 3 }, :type, 3 ],
    [ { :size => 1000 }, :size, 1000, :permissions ],
    [ { :owner => ENV['USER'] }, :owner, ENV['USER'] ],
    [ { :group => 'wheel' }, :group, 'wheel' ],
    [ { :uid => Etc.getpwnam(ENV['USER']).uid }, :owner, ENV['USER'] ],
    [ { :gid => Etc.getgrnam('wheel').gid }, :group, 'wheel' ],
    [ { :permissions => 0600 }, :permissions, 0600 ],
    [ { :atime => 1 }, :atime, 1 ],
    [ { :atime_nseconds => 2 }, :atime_nseconds, 2 ],
    [ { :ctime => 1 }, :ctime, 1 ],
    [ { :ctime_nseconds => 2 }, :ctime_nseconds, 2 ],
    [ { :mtime => 1 }, :mtime, 1 ],
    [ { :mtime_nseconds => 2 }, :mtime_nseconds, 2 ],
    [ { :acl => [ ACL.new(1,2,3,4), ACL.new(5,6,7,8) ] },
          :acl, [ ACL.new(1,2,3,4), ACL.new(5,6,7,8) ] ],
    [ { :extended => { "foo" => "bar" } }, :extended, { "foo" => "bar" } ]
  ].each do |fixture|
    define_method( "test_from_hash_#{fixture[1]}" ) do
      attrs = @factory.from_hash( fixture[0] )
      assert_equal fixture[2], attrs.__send__( fixture[1] )
      assert_nil attrs.__send__( fixture[3] || :size )
    end
  end

end
